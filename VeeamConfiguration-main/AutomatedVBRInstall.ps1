#Enable PowerShell Remote
Enable-PSRemoting -Force

#Disable Local Firewall
Set-NetFirewallProfile -Profile * -Enabled False

#Create HTTP listerner for WinRM connection
#New-Item -Path WSMan:\localhost\Listener\ -Transport HTTP -Address *

#Restart WinRM Service
Restart-Service WinRM

#Powershell security setting so we can run our scripts
set-executionpolicy bypass -Force
cd C:\_veeam

#Create Veeam Service Account
New-LocalUser -AccountNeverExpires:$true -Password ( ConvertTo-SecureString -AsPlainText -Force 'Veeam123!') -Name 'Veeam_SVC' | Add-LocalGroupMember -Group administrators

#Mount remote shares for scripts

Powershell.exe -file .\MountVBR_ISO.ps1

Powershell.exe -Command .\Install_Veeam.ps1 -InstallOption VBRServerInstall


