cd C:\_veeam

Import-Module Veeam.Backup.PowerShell
Import-Module -Name "C:\Program Files\Veeam\Backup and Replication\Console\Initialize-VeeamToolkit.ps1" -verbose
Get-VBRserver


#This will check the Veeam service has started and is running

$svc = Get-Service VeeamBackupSvc
$svc.WaitForStatus('Running')
Write-Progress -Activity "Waiting for Veeam services to start"


#XFSRepo_name = "TPM04-VBR-XFS-Rep01"
#XFSRepo_IP = "10.0.40.123"

#Variables
Add-VBRCredentials -User "domain\yourdomainadmin" -Password "Veeam123!" -Description "Veeam Service Account"
Add-VBRCredentials -type Linux -User "root" -Password "Veeam1!" -Description "CentOS Root / Veeam1!"
Add-VBRCredentials -type Linux -User "root" -Password "Veeam123!" -Description "Ubuntu Root / Veeam1!"

$WindowsCredential = Get-VBRCredentials -name "domain\yourdomainadmin"
$CentOSCredential = get-vbrcredentials | where {$_.description -like "CentOS Root / Veeam1!"}
$UbuntuOSCredential = get-vbrcredentials | where {$_.description -like "Ubuntu Root / Veeam123!"}

$vbrserver = hostname
$WinProxy = "10.0.40.121"
$WinProxyName = "TPM04-PRX-WIN01.yourdomain.tld"
$LinProxy = "10.0.40.122"


#Add Windows Proxy
Add-VBRWinServer -Name $WinProxyName -Description "Windows File & VMware Proxy" -Credentials $WindowsCredential -ErrorAction Stop | Out-Null
Add-VBRViProxy -Server $WinProxyName
Add-VBRNASProxyServer -Server $WinProxyName -ConcurrentTaskNumber 2 | Out-Null

#Add Linux Proxy
Add-VBRLinux -Name $LinProxy -Description "Linux VMware Proxy" -Credentials $CentOSCredential -ErrorAction Stop | Out-Null
Add-VBRViLinuxProxy -Server $LinProxy

#Add Linux Repository
#add managed server (single access credentials)
#add repository role with XFS and Immutable flag

#Add vSphere Environment
Add-VBRvCenter -Name "yourvc.domain.tld" -User "Administrator@vsphere.local" -Password "ASecurePassword" -Description "Mega Lab VC"


#Add NAS Share
Resize-Partition -DriveLetter C -Size $(Get-PartitionSupportedSize -DriveLetter C).SizeMax
new-item c:\CacheRepository -itemtype directory
Add-VBRBackupRepository -Name "NAS Cache Repository" -Server $vbrserver -Folder "c:\CacheRepository" -Type WinLocal
$CacheRepository = Get-VBRBackupRepository -Name "NAS Cache Repository"
Add-VBRNASSMBServer -Path "\\dc1\share\backup" -AccessCredentials $WindowsCredential -CacheRepository $CacheRepository

#Create Scale Out Backup Repository
new-item c:\PerformanceTier -itemtype directory
Add-VBRBackupRepository -Name "Performance Tier" -Server $vbrserver -Folder "c:\PerformanceTier" -Type WinLocal
Add-VBRScaleOutBackupRepository -Name "Veeam Scale-Out Repository" –PolicyType Performance –Extent “Performance Tier”
$repository = Get-VBRBackupRepository -ScaleOut -Name "Veeam Scale-Out Repository"

#Add Capacity Tier
#AWS
#Azure Storage - Possibly have something on home desktop machine to test.
#GCP

#Create Veeam VMware Backup Job
Find-VBRViEntity -Name TPM04-CENTOS-01 | Add-VBRViBackupJob -Name "VMware - Web Server Backup" -BackupRepository $repository -Description "Automated VMware Web Server Backup"

#Create NAS Backup job
$NASserver = Get-VBRNASServer -Name "\\dc1\share\backup"
$NASobject = New-VBRNASBackupJobObject -Server $NASserver -Path "\\dc1\share\cade"
Add-VBRNASBackupJob -BackupObject $NASobject -ShortTermBackupRepository $repository -Name "NAS Backup Job" -Description "Automated VMware Web Server Backup"

#Create Virtual Lab
#Create Application Group
#Create SureBackup Job
