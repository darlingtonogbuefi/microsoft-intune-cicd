# Ensure NuGet is installed for module management
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
}

# Trust PSGallery if not already trusted
$repo = Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue
if ($repo -and $repo.InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
}

### ------------------------
### PowerShellGet and PackageManagement
### ------------------------

if (-not (Get-InstalledModule -Name PackageManagement -ErrorAction SilentlyContinue)) {
    Install-Module -Name PackageManagement -Force -Scope CurrentUser -AllowClobber
}

if (-not (Get-InstalledModule -Name PowerShellGet -ErrorAction SilentlyContinue)) {
    Install-Module -Name PowerShellGet -Force -Scope CurrentUser -AllowClobber
}

### ------------------------
### Pester Management
### ------------------------

$latestPesterVersion = (Find-Module -Name Pester).Version
$installedPesterModules = Get-InstalledModule -Name Pester -AllVersions -ErrorAction SilentlyContinue

foreach ($module in $installedPesterModules) {
    if ($module.Version -ne $latestPesterVersion) {
        Uninstall-Module -Name Pester -RequiredVersion $module.Version -Force -ErrorAction SilentlyContinue
    }
}

if (-not ($installedPesterModules | Where-Object { $_.Version -eq $latestPesterVersion })) {
    Install-Module -Name Pester -RequiredVersion $latestPesterVersion -Force -Scope CurrentUser -AllowClobber -SkipPublisherCheck
}
Import-Module Pester -Force

### ------------------------
### Az.Accounts Module
### ------------------------

if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
    Install-Module -Name Az.Accounts -Force -Scope AllUsers
}
Import-Module Az.Accounts -Force

### ------------------------
### Microsoft.Graph Module
### ------------------------

$latestGraphVersion = (Find-Module -Name Microsoft.Graph).Version
$installedGraphModules = Get-InstalledModule -Name Microsoft.Graph -AllVersions -ErrorAction SilentlyContinue

foreach ($module in $installedGraphModules) {
    if ($module.Version -ne $latestGraphVersion) {
        Uninstall-Module -Name Microsoft.Graph -RequiredVersion $module.Version -Force -ErrorAction SilentlyContinue
    }
}

if (-not ($installedGraphModules | Where-Object { $_.Version -eq $latestGraphVersion })) {
    Install-Module -Name Microsoft.Graph -RequiredVersion $latestGraphVersion -Force -Scope AllUsers
}

# Only import if not already loaded
if (-not (Get-Module Microsoft.Graph.DeviceManagement.Administration)) {
    Import-Module Microsoft.Graph.DeviceManagement.Administration
}


### ------------------------
### Azure CLI
### ------------------------

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    $azInstaller = "$env:TEMP\AzureCLI.msi"
    Invoke-WebRequest -Uri "https://aka.ms/installazurecliwindows" -OutFile $azInstaller
    Start-Process msiexec.exe -ArgumentList "/i", "`"$azInstaller`"", "/quiet", "/norestart" -Wait
    Remove-Item $azInstaller -Force
}

### ------------------------
### Python
### ------------------------

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    $pythonInstaller = "$env:TEMP\python-installer.exe"
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe" -OutFile $pythonInstaller
    Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait
    Remove-Item $pythonInstaller -Force
}

### ------------------------
### PowerShell CLI 7.5.2 (pwsh)
### ------------------------

if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    $pwshInstaller = "$env:TEMP\PowerShell-7.msi"
    Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.5.2/PowerShell-7.5.2-win-x64.msi" -OutFile $pwshInstaller
    Start-Process msiexec.exe -ArgumentList "/i", "`"$pwshInstaller`"", "/quiet", "/norestart" -Wait
    Remove-Item $pwshInstaller -Force
}

# Confirm it's in PATH
$pwshPath = "$Env:ProgramFiles\PowerShell\7\pwsh.exe"
if (Test-Path $pwshPath) {
    [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";$($pwshPath | Split-Path)", [EnvironmentVariableTarget]::Machine)
}

# Create shortcut for PowerShell 7 (optional)
$shortcutPath = "$env:Public\Desktop\PowerShell 7.lnk"
$wshell = New-Object -ComObject WScript.Shell
$shortcut = $wshell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $pwshPath
$shortcut.WorkingDirectory = "$env:USERPROFILE"
$shortcut.WindowStyle = 1
$shortcut.IconLocation = "$pwshPath,0"
$shortcut.Save()

Write-Host "Environment setup complete."
