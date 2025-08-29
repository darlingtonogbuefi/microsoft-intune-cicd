# Enable WinRM HTTP (port 5985)
winrm quickconfig -force
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value true
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value true
Enable-PSRemoting -Force
