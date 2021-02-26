$hostName = $env:COMPUTERNAME
$serverCert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName $hostName
$serverCert 
Export-Certificate -Cert $serverCert -FilePath C:\PsRemoting-Cert.cer
Get-ChildItem C:\PsRemoting-Cert.cer
Enable-PSRemoting -Force
Get-ChildItem wsman:\localhost\Listener\ | Where-Object -Property Keys -eq 'Transport=HTTP' | Remove-Item -Recurse
New-Item -Path WSMan:\localhost\Listener\ -Transport HTTPS -Address * -CertificateThumbPrint $serverCert.Thumbprint -Force
#http://vcloud-lab.com/entries/powershell/powershell-remoting-over-https-using-self-signed-ssl-certificate
Restart-Service WinRM