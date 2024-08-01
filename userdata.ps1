#This script is used to prepare a freshly created Windows Machine to be installed in a lab environment for Veeam Software installation. As part of a Terraform apply this script is called remotely from this repository and makes these changes to the Windows Server. 

# Set the execution policy to unrestricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore
$ErrorActionPreference = "stop"

# Create a directory for Veeam (this is only needed if you are using PowerShell automated installs, not if Ansible is used)
New-Item -Path "c:\" -Name "_veeam" -ItemType "directory"

#Set Windows Firewall to OFF
set-NetFirewallProfile -All -Enabled False

# Install and configure OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Get-Service sshd | Set-Service -StartupType Automatic
Start-Service sshd

# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
