# Check if Microsoft Defender is installed, running, and up to date
Write-Host "Checking Microsoft Defender for Endpoint status..." -ForegroundColor Cyan

# Function to check if a service exists and is running
function Test-ServiceRunning {
    param (
        [string]$ServiceName
    )
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        return $true
    }
    return $false
}

# Function to check Defender Antivirus status
function Get-DefenderStatus {
    $status = Get-MpComputerStatus

    return [PSCustomObject]@{
        AMServiceEnabled           = $status.AMServiceEnabled
        AntivirusEnabled           = $status.AntivirusEnabled
        RealTimeProtectionEnabled  = $status.RealTimeProtectionEnabled
        AntivirusSignatureUpdated  = ($status.AntivirusSignatureLastUpdated -gt (Get-Date).AddDays(-1))
        SignatureVersion           = $status.AntivirusSignatureVersion
        NISSignatureLastUpdated    = $status.NISSignatureLastUpdated
        QuickScanEndTime           = $status.QuickScanEndTime
        FullScanEndTime            = $status.FullScanEndTime
    }
}

# Function to check MDE sensor health via registry
function Get-MDESensorStatus {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status"
    if (Test-Path $regPath) {
        $sensorHealth = Get-ItemProperty -Path $regPath
        return [PSCustomObject]@{
            SenseIsRunning = $sensorHealth.SenseIsRunning
            OnboardingState = $sensorHealth.OnboardingState
            OrgId = $sensorHealth.OrgId
            DeviceName = $sensorHealth.DeviceName
        }
    } else {
        return $null
    }
}

# Start checks
$defenderServiceOK = Test-ServiceRunning -ServiceName "WinDefend"
$mdeSensorOK = Test-ServiceRunning -ServiceName "Sense"
$defenderStatus = Get-DefenderStatus
$mdeStatus = Get-MDESensorStatus

# Output summary
Write-Host "`n===== Defender Status Summary =====" -ForegroundColor Yellow

if ($defenderServiceOK) {
    Write-Host "✔ Microsoft Defender Antivirus service is running."
} else {
    Write-Host "✘ Microsoft Defender Antivirus service is NOT running." -ForegroundColor Red
}

if ($mdeSensorOK) {
    Write-Host "✔ Microsoft Defender for Endpoint Sensor service is running."
} else {
    Write-Host "✘ Microsoft Defender for Endpoint Sensor is NOT running." -ForegroundColor Red
}

if ($defenderStatus.RealTimeProtectionEnabled) {
    Write-Host "✔ Real-time protection is enabled."
} else {
    Write-Host "✘ Real-time protection is DISABLED." -ForegroundColor Red
}

if ($defenderStatus.AntivirusSignatureUpdated) {
    Write-Host "✔ Antivirus definitions are up to date."
} else {
    Write-Host "✘ Antivirus definitions are OUTDATED." -ForegroundColor Red
}

Write-Host "Antivirus Signature Version: $($defenderStatus.SignatureVersion)"
Write-Host "Last Quick Scan: $($defenderStatus.QuickScanEndTime)"
Write-Host "Last Full Scan: $($defenderStatus.FullScanEndTime)"

if ($mdeStatus) {
    Write-Host "`nMDE Sensor Registry Info:"
    Write-Host "  - SenseIsRunning: $($mdeStatus.SenseIsRunning)"
    Write-Host "  - OnboardingState: $($mdeStatus.OnboardingState)"
    Write-Host "  - OrgId: $($mdeStatus.OrgId)"
    Write-Host "  - DeviceName: $($mdeStatus.DeviceName)"
} else {
    Write-Host "✘ MDE registry status not found. Sensor may not be installed." -ForegroundColor Red
}

Write-Host "`nCheck completed." -ForegroundColor Green
