<#
.SYNOPSIS
Simple Compliance Policy Script

.DESCRIPTION
This script performs a basic compliance check:
1. Verifies the OS version is Windows 10 or higher.
2. Checks if Windows Defender service is running.
Returns "compliance passed" if both checks succeed.
#>

function Get-ComplianceStatus {
    # Check OS version (Windows 10 or higher)
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Write-Error "Operating system version is below Windows 10."
        return "NonCompliant"
    }

    # Check if Windows Defender service is running
    $serviceName = 'WinDefend'
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Error "Service $serviceName not found."
        return "NonCompliant"
    }

    if ($service.Status -ne 'Running') {
        Write-Error "Service $serviceName is not running."
        return "NonCompliant"
    }

    return "Compliant"
}

Write-Output "Starting compliance check..."

$status = Get-ComplianceStatus

if ($status -eq "Compliant") {
    Write-Output "compliance passed"
    exit 0
} else {
    Write-Output "compliance failed"
    exit 1
}
