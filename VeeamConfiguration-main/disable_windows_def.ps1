Set-MpPreference -DisableRealtimeMonitoring $true
Set-Itemproperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\policies\system' -Name 'EnableLUA' -value 0