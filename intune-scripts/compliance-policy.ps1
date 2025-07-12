# Example compliance policy script
param ()

Write-Host "Starting compliance check..."

# Sample compliance logic — check if Windows Defender service is running
$serviceName = 'WinDefend'
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Error "Service $serviceName not found."
    exit 1
}
<#
.SYNOPSIS
Simple Compliance Policy Script

.DESCRIPTION
This script performs a basic compliance check and outputs "compliance passed" if successful.
#>

function Get-ComplianceStatus {
    # Example compliance check (customize as needed)
    # Here, we check if the OS is Windows 10 or higher

    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -ge 10) {
        return "Compliant"
    } else {
        return "NonCompliant"
    }
}

$status = Get-ComplianceStatus

if ($status -eq "Compliant") {
    Write-Output "compliance passed"
    exit 0
} else {
    Write-Output "compliance failed"
    exit 1
}

if ($service.Status -ne 'Running') {
    Write-Error "Service $serviceName is not running."
    exit 1
}

Write-Host "Service $serviceName is running — compliance passed."
exit 0
