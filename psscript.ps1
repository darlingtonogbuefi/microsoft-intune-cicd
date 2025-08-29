# psscript.ps1

winrm quickconfig -quiet
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
Enable-PSRemoting -Force

# Open firewall for WinRM

New-NetFirewallRule -DisplayName "Allow WinRM" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow

