$isodrive = (Get-Volume -FileSystemLabel "VEEAM BACKUP").DriveLetter
$msipath = $isodrive+":\Packages\"

$msipackage = "VAMRedist.msi"
$msiargs = '/i '+$msipath+$msipackage+' ACCEPTEULA="1" ACCEPT_THIRDPARTY_LICENSES="1" /l VAMlogfile.txt /q'
Start-Process 'msiexec.exe' -ArgumentList $msiargs -Wait -NoNewWindow

$msipackage = "VALRedist.msi"
$msiargs = '/i '+$msipath+$msipackage+' ACCEPTEULA="1" ACCEPT_THIRDPARTY_LICENSES="1" /l VAMlogfile.txt /q'
Start-Process 'msiexec.exe' -ArgumentList $msiargs -Wait -NoNewWindow


$msipackage = "VAWRedist.msi"
$msiargs = '/i '+$msipath+$msipackage+' ACCEPTEULA="1" ACCEPT_THIRDPARTY_LICENSES="1" /l VAMlogfile.txt /q'
Start-Process 'msiexec.exe' -ArgumentList $msiargs -Wait -NoNewWindow

