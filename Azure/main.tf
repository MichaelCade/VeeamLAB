provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

variable "subscription_id" {
  description = "The subscription ID for Azure"
  type        = string
}

variable "client_ip" {
  description = "The IP address of the client that needs access to the Azure SQL Server"
  type        = string
}

# Common tags
locals {
  common_tags = {
    demo-vbazure-all = "true"
  }
}

# Resource Group
resource "azurerm_resource_group" "demo-vbazure" {
  name     = "demo-vbazure-resources"
  location = "UK South"
  tags     = local.common_tags
}

# Azure VM
resource "azurerm_virtual_network" "demo-vbazure" {
  name                = "demo-vbazure-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.demo-vbazure.location
  resource_group_name = azurerm_resource_group.demo-vbazure.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "demo-vbazure" {
  name                 = "demo-vbazure-subnet"
  resource_group_name  = azurerm_resource_group.demo-vbazure.name
  virtual_network_name = azurerm_virtual_network.demo-vbazure.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "demo-vbazure" {
  count               = 3
  name                = "demo-vbazure-nic-${count.index}"
  location            = azurerm_resource_group.demo-vbazure.location
  resource_group_name = azurerm_resource_group.demo-vbazure.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo-vbazure.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "demo-vbazure" {
  count                 = 3
  name                  = "demo-vbazure-vm-${count.index}"
  location              = azurerm_resource_group.demo-vbazure.location
  resource_group_name   = azurerm_resource_group.demo-vbazure.name
  network_interface_ids = [element(azurerm_network_interface.demo-vbazure.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"
  tags                  = local.common_tags

  storage_os_disk {
    name              = "demo-vbazure-os-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "demo-vbazure-vm-${count.index}"
    admin_username = "adminuser"
    admin_password = "var.password"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Azure SQL Database
resource "azurerm_mssql_server" "demo-vbazure" {
  name                         = "demo-vbazure-sqlserver"
  resource_group_name          = azurerm_resource_group.demo-vbazure.name
  location                     = azurerm_resource_group.demo-vbazure.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "var.password"
  tags                         = local.common_tags
}

resource "azurerm_mssql_database" "demo-vbazure" {
  name      = "demo-vbazure-sqldb"
  server_id = azurerm_mssql_server.demo-vbazure.id
  sku_name  = "Basic"
  tags      = local.common_tags
}

# Add the firewall rule to allow access from the client IP
resource "azurerm_mssql_firewall_rule" "demo-vbazure_client_ip" {
  name            = "AllowClientIP"
  server_id       = azurerm_mssql_server.demo-vbazure.id
  start_ip_address = var.client_ip
  end_ip_address   = var.client_ip
}

# Add the firewall rule to allow access from Azure services
resource "azurerm_mssql_firewall_rule" "demo-vbazure_azure_services" {
  name            = "AllowAzureServices"
  server_id       = azurerm_mssql_server.demo-vbazure.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Cosmos DB for PostgreSQL
resource "azurerm_cosmosdb_postgresql_cluster" "demo-vbazure" {
  name                = "demo-vbazure-cosmosdb"
  location            = azurerm_resource_group.demo-vbazure.location
  resource_group_name = azurerm_resource_group.demo-vbazure.name
  node_count          = 0
  administrator_login_password = "var.password"
  coordinator_storage_quota_in_mb = 65536
  coordinator_vcore_count = 1
  node_storage_quota_in_mb = 524288  
  node_vcores = 4
  coordinator_server_edition      = "BurstableMemoryOptimized"
  node_server_edition             = "MemoryOptimized"
  tags = local.common_tags 
}

# Allow access from Azure services
resource "azurerm_cosmosdb_postgresql_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  cluster_id          = azurerm_cosmosdb_postgresql_cluster.demo-vbazure.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Azure File Share
resource "azurerm_storage_account" "demo-vbazure" {
  name                     = "demovbazurestorageacct"
  resource_group_name      = azurerm_resource_group.demo-vbazure.name
  location                 = azurerm_resource_group.demo-vbazure.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags
}

resource "azurerm_storage_share" "demo-vbazure" {
  name               = "demovbazureshare"
  storage_account_id = azurerm_storage_account.demo-vbazure.id
  quota              = 50
}

# Azure Data Lake
resource "azurerm_storage_account" "demo-vbazure_datalake" {
  name                     = "demovbazuredatalake"
  resource_group_name      = azurerm_resource_group.demo-vbazure.name
  location                 = azurerm_resource_group.demo-vbazure.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  tags                     = local.common_tags
}

# Azure Blob Storage
resource "azurerm_storage_container" "demo-vbazure_blob" {
  name                  = "demovbazureblob"
  storage_account_id    = azurerm_storage_account.demo-vbazure.id
  container_access_type = "private"
}

# Outputs
output "sql_server_fqdn" {
  value     = azurerm_mssql_server.demo-vbazure.fully_qualified_domain_name
  sensitive = true
}

output "sql_database_name" {
  value     = azurerm_mssql_database.demo-vbazure.name
  sensitive = true
}

output "cosmosdb_primary_key" {
  value     = azurerm_cosmosdb_postgresql_cluster.demo-vbazure.administrator_login_password
  sensitive = true
}

output "storage_account_name" {
  value     = azurerm_storage_account.demo-vbazure.name
  sensitive = true
}

output "storage_account_primary_access_key" {
  value     = azurerm_storage_account.demo-vbazure.primary_access_key
  sensitive = true
}

output "vm_public_ips" {
  value     = azurerm_network_interface.demo-vbazure.*.private_ip_address
  sensitive = true
}