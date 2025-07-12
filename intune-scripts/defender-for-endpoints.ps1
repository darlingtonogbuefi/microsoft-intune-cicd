<#
.SYNOPSIS
Checks if Microsoft Defender Antivirus and Microsoft Defender for Endpoint (MDE) are installed, running, and up to date.
#>

# Function: Check if a service exists and is running
function Test-ServiceRunning {
    param (
        [string]$ServiceName
    )
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    return ($service -and $service.Status -eq 'Running')
}

# Function: Get Defender Antivirus status (with error handling)
function Get-DefenderStatus {
    try {
        $status = Get-MpComputerStatus
        return [PSCustomObject]@{
            AMServiceEnabled          = $status.AMServiceEnabled
            AntivirusEnabled          = $status.AntivirusEnabled
            RealTimeProtectionEnabled = $status.RealTimeProtectionEnabled
            AntivirusSignatureUpdated = ($status.AntivirusSignatureLastUpdated -gt (Get-Date).AddDays(-1))
            SignatureVersion          = $status.AntivirusSignatureVersion
            NISSignatureLastUpdated   = $status.NISSignatureLastUpdated
            QuickScanEndTime          = $status.QuickScanEndTime
            FullScanEndTime           = $status.FullScanEndTime
        }
    } catch {
        Write-Warning "Unable to retrieve Defender status. Microsoft Defender may not be installed."
        return $null
    }
}

# Function: Check MDE Sensor registry status
function Get-MDESensorStatus {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status"
    if (Test-Path $regPath) {
        $sensorHealth = Get-ItemProperty -Path $regPath
        return [PSCustomObject]@{
            SenseIsRunning  = $sensorHealth.SenseIsRunning
            OnboardingState = $sensorHealth.OnboardingState
            OrgId           = $sensorHealth.OrgId
            DeviceName      = $sensorHealth.DeviceName
        }
    } else {
        return $null
    }
}

Write-Output "🔍 Checking Microsoft Defender for Endpoint status..."

# Execute checks
$defenderServiceOK = Test-ServiceRunning -ServiceName "WinDefend"
$mdeSensorOK       = Test-ServiceRunning -ServiceName "Sense"
$defenderStatus    = Get-DefenderStatus
$mdeStatus         = Get-MDESensorStatus

# Display summary
Write-Output "`n===== Defender Status Summary ====="

if ($defenderServiceOK) {
    Write-Output "Microsoft Defender Antivirus service is running."
} else {
    Write-Output "Microsoft Defender Antivirus service is NOT running."
}

if ($mdeSensorOK) {
    Write-Output "✔ Microsoft Defender for Endpoint Sensor service is running."
} else {
    Write-Output "✘ Microsoft Defender for Endpoint Sensor is NOT running."
}

if ($defenderStatus) {
    if ($defenderStatus.RealTimeProtectionEnabled) {
        Write-Output "Real-time protection is enabled."
    } else {
        Write-Output "Real-time protection is DISABLED."
    }

    if ($defenderStatus.AntivirusSignatureUpdated) {
        Write-Output "Antivirus definitions are up to date."
    } else {
        Write-Output "Antivirus definitions are OUTDATED."
    }

    Write-Output "Antivirus Signature Version: $($defenderStatus.SignatureVersion)"
    Write-Output "Last Quick Scan: $($defenderStatus.QuickScanEndTime)"
    Write-Output "Last Full Scan: $($defenderStatus.FullScanEndTime)"
} else {
    Write-Output "Defender status information not available."
}

if ($mdeStatus) {
    Write-Output "`nMDE Sensor Registry Info:"
    Write-Output "  - SenseIsRunning: $($mdeStatus.SenseIsRunning)"
    Write-Output "  - OnboardingState: $($mdeStatus.OnboardingState)"
    Write-Output "  - OrgId: $($mdeStatus.OrgId)"
    Write-Output "  - DeviceName: $($mdeStatus.DeviceName)"
} else {
    Write-Output "MDE registry status not found. Sensor may not be installed."
}

Write-Output "`nCheck completed."
