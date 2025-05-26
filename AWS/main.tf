# AWS Provider Configuration
provider "aws" {
  region  = var.region
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "client_ip" {
  description = "The IP address of the client that needs access to the AWS resources"
  type        = string
}

variable "db_password" {
  description = "Password for database users"
  type        = string
  sensitive   = true
}

# Common tags
locals {
  common_tags = {
    demo-vbaws-all = "true"
  }
}

# VPC
resource "aws_vpc" "demo-vbaws" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.common_tags, { Name = "demo-vbaws-vpc" })
}

# Subnets
resource "aws_subnet" "demo-vbaws-public" {
  count             = 3
  vpc_id            = aws_vpc.demo-vbaws.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = "${var.region}${["a", "b", "c"][count.index]}"
  tags              = merge(local.common_tags, { Name = "demo-vbaws-public-${count.index}" })
}

resource "aws_subnet" "demo-vbaws-private" {
  count             = 3
  vpc_id            = aws_vpc.demo-vbaws.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = "${var.region}${["a", "b", "c"][count.index]}"
  tags              = merge(local.common_tags, { Name = "demo-vbaws-private-${count.index}" })
}

# Internet Gateway
resource "aws_internet_gateway" "demo-vbaws" {
  vpc_id = aws_vpc.demo-vbaws.id
  tags   = merge(local.common_tags, { Name = "demo-vbaws-igw" })
}

# Route Tables
resource "aws_route_table" "demo-vbaws-public" {
  vpc_id = aws_vpc.demo-vbaws.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-vbaws.id
  }
  tags = merge(local.common_tags, { Name = "demo-vbaws-public-rt" })
}

# Route Table Association
resource "aws_route_table_association" "demo-vbaws-public" {
  count          = 3
  subnet_id      = aws_subnet.demo-vbaws-public[count.index].id
  route_table_id = aws_route_table.demo-vbaws-public.id
}

# Security Group
resource "aws_security_group" "demo-vbaws" {
  name        = "demo-vbaws-sg"
  description = "Allow SSH and other necessary traffic"
  vpc_id      = aws_vpc.demo-vbaws.id

  # SSH from client IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.client_ip}/32"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "demo-vbaws-sg" })
}

# EC2 Instances
resource "aws_instance" "demo-vbaws" {
  count                       = 3
  ami                         = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS in us-east-1
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.demo-vbaws-public[count.index % 3].id
  vpc_security_group_ids      = [aws_security_group.demo-vbaws.id]
  associate_public_ip_address = true
  key_name                    = "demo-vbaws-key"  # You'll need to create this key pair in AWS first

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = merge(local.common_tags, { Name = "demo-vbaws-ec2-${count.index}" })
}

# RDS PostgreSQL
resource "aws_security_group" "demo-vbaws-db" {
  name        = "demo-vbaws-db-sg"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.demo-vbaws.id

  # Allow traffic from EC2 instances
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.demo-vbaws.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "demo-vbaws-db-sg" })
}

resource "aws_db_subnet_group" "demo-vbaws" {
  name       = "demo-vbaws-db-subnet-group"
  subnet_ids = aws_subnet.demo-vbaws-private.*.id
  tags       = local.common_tags
}

resource "aws_db_parameter_group" "demo-vbaws-postgres" {
  name   = "demo-vbaws-postgres-params"
  family = "postgres17"
  tags   = local.common_tags
}

resource "aws_db_instance" "demo-vbaws-postgres" {
  identifier              = "demo-vbaws-postgres"
  engine                  = "postgres"
  engine_version          = "17.2"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = "dbadmin"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.demo-vbaws.name
  vpc_security_group_ids  = [aws_security_group.demo-vbaws-db.id]
  parameter_group_name    = aws_db_parameter_group.demo-vbaws-postgres.name
  skip_final_snapshot     = true
  backup_retention_period = 7
  multi_az               = false
  tags                   = merge(local.common_tags, { Name = "demo-vbaws-postgres" })
}

# RDS MySQL
resource "aws_db_parameter_group" "demo-vbaws-mysql" {
  name   = "demo-vbaws-mysql-params"
  family = "mysql8.0"
  tags   = local.common_tags
}

resource "aws_db_instance" "demo-vbaws-mysql" {
  identifier              = "demo-vbaws-mysql"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = "dbadmin"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.demo-vbaws.name
  vpc_security_group_ids  = [aws_security_group.demo-vbaws-db.id]
  parameter_group_name    = aws_db_parameter_group.demo-vbaws-mysql.name
  skip_final_snapshot     = true
  backup_retention_period = 7
  multi_az               = false
  tags                   = merge(local.common_tags, { Name = "demo-vbaws-mysql" })
}

# DynamoDB
resource "aws_dynamodb_table" "demo-vbaws" {
  name           = "demo-vbaws-dynamodb"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = merge(local.common_tags, { Name = "demo-vbaws-dynamodb" })
}

# Redshift
resource "aws_redshift_subnet_group" "demo-vbaws" {
  name       = "demo-vbaws-redshift-subnet-group"
  subnet_ids = aws_subnet.demo-vbaws-private.*.id
  tags       = local.common_tags
}

resource "aws_security_group" "demo-vbaws-redshift" {
  name        = "demo-vbaws-redshift-sg"
  description = "Allow redshift traffic"
  vpc_id      = aws_vpc.demo-vbaws.id

  ingress {
    from_port       = 5439
    to_port         = 5439
    protocol        = "tcp"
    security_groups = [aws_security_group.demo-vbaws.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "demo-vbaws-redshift-sg" })
}

resource "aws_redshift_cluster" "demo-vbaws" {
  cluster_identifier        = "demo-vbaws-redshift"
  database_name             = "devdb"
  master_username           = "dbadmin"
  master_password           = var.db_password
  node_type                 = "dc2.large"
  cluster_type              = "single-node"
  vpc_security_group_ids    = [aws_security_group.demo-vbaws-redshift.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.demo-vbaws.name
  skip_final_snapshot       = true
  publicly_accessible       = false
  tags                      = merge(local.common_tags, { Name = "demo-vbaws-redshift" })
}

# Redshift Serverless
resource "aws_redshiftserverless_namespace" "demo-vbaws" {
  namespace_name = "demo-vbaws-redshift-serverless"
  admin_username = "dbadmin"
  admin_user_password = var.db_password
  db_name = "devdb"
  tags = local.common_tags
}

resource "aws_redshiftserverless_workgroup" "demo-vbaws" {
  namespace_name = aws_redshiftserverless_namespace.demo-vbaws.namespace_name
  workgroup_name = "demo-vbaws-redshift-serverless-wg"
  base_capacity = 8
  subnet_ids    = aws_subnet.demo-vbaws-private.*.id
  security_group_ids = [aws_security_group.demo-vbaws-redshift.id]
  tags = local.common_tags
}

# EFS
resource "aws_security_group" "demo-vbaws-efs" {
  name        = "demo-vbaws-efs-sg"
  description = "Allow EFS traffic"
  vpc_id      = aws_vpc.demo-vbaws.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.demo-vbaws.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "demo-vbaws-efs-sg" })
}

resource "aws_efs_file_system" "demo-vbaws" {
  creation_token = "demo-vbaws-efs"
  encrypted      = true
  tags           = merge(local.common_tags, { Name = "demo-vbaws-efs" })
}

resource "aws_efs_mount_target" "demo-vbaws" {
  count           = 3
  file_system_id  = aws_efs_file_system.demo-vbaws.id
  subnet_id       = aws_subnet.demo-vbaws-private[count.index].id
  security_groups = [aws_security_group.demo-vbaws-efs.id]
}

# Outputs
output "vpc_id" {
  value = aws_vpc.demo-vbaws.id
}

output "ec2_public_ips" {
  value     = aws_instance.demo-vbaws.*.public_ip
  sensitive = true
}

output "rds_postgres_endpoint" {
  value     = aws_db_instance.demo-vbaws-postgres.endpoint
  sensitive = true
}

output "rds_mysql_endpoint" {
  value     = aws_db_instance.demo-vbaws-mysql.endpoint
  sensitive = true
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.demo-vbaws.name
}

output "redshift_endpoint" {
  value     = aws_redshift_cluster.demo-vbaws.endpoint
  sensitive = true
}

output "redshift_serverless_endpoint" {
  value     = aws_redshiftserverless_workgroup.demo-vbaws.endpoint
  sensitive = true
}

output "efs_id" {
  value = aws_efs_file_system.demo-vbaws.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.demo-vbaws.dns_name
}