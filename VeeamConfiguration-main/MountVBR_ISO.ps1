 #Variable Decalration
$isoImg = (ChildItem -Path ./ISO -Filter  *Veeam**.iso* | Select-Object Name).name

#Mount ISO and Gather Drive Letter
Mount-DiskImage -ImagePath ((Get-Item -Path ".\ISO\" -Verbose).Fullname+$isoImg) -PassThru | Out-Null
