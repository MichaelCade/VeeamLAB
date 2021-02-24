
 
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore
$ErrorActionPreference = "stop"


New-Item -Path "c:\" -Name "logfiles" -ItemType "directory"

#Set Windows Firewall to OFF
set-NetFirewallProfile -All -Enabled False

#Create User and Add to Local Administrator Group
$password = ConvertTo-SecureString 'Veeam1!' -AsPlainText -Force
new-localuser -Name autodeploy -Password $password
add-localgroupmember -Group administrators -Member autodeploy

Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Get-Service sshd | Set-Service -StartupType Automatic
Start-Service sshd
