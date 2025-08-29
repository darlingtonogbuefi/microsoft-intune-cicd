<#
.SYNOPSIS
Deploys Managed App Protection policies (iOS & Android) to Intune using Microsoft Graph via Service Principal.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$TenantId,
    [Parameter(Mandatory = $true)][string]$ClientId,
    [Parameter(Mandatory = $true)][string]$ClientSecret
)

function Get-GraphToken {
    param (
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )

    $body = @{
        grant_type    = "client_credentials"
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = "https://graph.microsoft.com/.default"
    }

    $response = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $body
    return $response.access_token
}

function Invoke-GraphPost {
    param (
        [string]$Uri,
        [string]$Token,
        [string]$Body
    )

    try {
        $headers = @{
            "Authorization" = "Bearer $Token"
            "Content-Type"  = "application/json"
        }

        Invoke-RestMethod -Method POST -Uri $Uri -Headers $headers -Body $Body
        Write-Output "Policy posted to $Uri"
    } catch {
        Write-Error "Failed to POST to $Uri"
        Write-Error $_.Exception.Message
        exit 1
    }
}

# Load iOS Managed App Policy JSON
$iOSPolicy = @"
{
  "@odata.type": "#microsoft.graph.iosManagedAppProtection",
  "displayName": "CI MAM iOS Policy",
  "description": "CI MAM iOS Policy",
  "periodOfflineBeforeAccessCheck": "PT12H",
  "periodOnlineBeforeAccessCheck": "PT30M",
  "allowedInboundDataTransferSources": "allApps",
  "allowedOutboundDataTransferDestinations": "allApps",
  "organizationalCredentialsRequired": false,
  "allowedOutboundClipboardSharingLevel": "allApps",
  "dataBackupBlocked": true,
  "deviceComplianceRequired": true,
  "managedBrowserToOpenLinksRequired": true,
  "saveAsBlocked": true,
  "periodOfflineBeforeWipeIsEnforced": "P90D",
  "pinRequired": true,
  "maximumPinRetries": 5,
  "simplePinBlocked": true,
  "minimumPinLength": 4,
  "pinCharacterSet": "numeric",
  "allowedDataStorageLocations": [],
  "contactSyncBlocked": true,
  "printBlocked": true,
  "fingerprintBlocked": true,
  "appDataEncryptionType": "afterDeviceRestart",
  "apps": [
    {
      "mobileAppIdentifier": {
        "@odata.type": "#microsoft.graph.iosMobileAppIdentifier",
        "bundleId": "com.microsoft.office.outlook"
      }
    },
    {
      "mobileAppIdentifier": {
        "@odata.type": "#microsoft.graph.iosMobileAppIdentifier",
        "bundleId": "com.microsoft.office.excel"
      }
    }
  ]
}
"@

# Load Android Managed App Policy JSON
$androidPolicy = @"
{
  "@odata.type": "#microsoft.graph.androidManagedAppProtection",
  "displayName": "CI MAM Android Policy",
  "description": "CI MAM Android Policy",
  "periodOfflineBeforeAccessCheck": "PT12H",
  "periodOnlineBeforeAccessCheck": "PT30M",
  "allowedInboundDataTransferSources": "allApps",
  "allowedOutboundDataTransferDestinations": "allApps",
  "organizationalCredentialsRequired": false,
  "allowedOutboundClipboardSharingLevel": "allApps",
  "dataBackupBlocked": true,
  "deviceComplianceRequired": true,
  "managedBrowserToOpenLinksRequired": true,
  "saveAsBlocked": true,
  "periodOfflineBeforeWipeIsEnforced": "P90D",
  "pinRequired": true,
  "maximumPinRetries": 5,
  "simplePinBlocked": true,
  "minimumPinLength": 4,
  "pinCharacterSet": "numeric",
  "allowedDataStorageLocations": [],
  "contactSyncBlocked": true,
  "printBlocked": true,
  "fingerprintBlocked": true,
  "appDataEncryptionType": "afterDeviceRestart",
  "apps": [
    {
      "mobileAppIdentifier": {
        "@odata.type": "#microsoft.graph.androidMobileAppIdentifier",
        "packageId": "com.microsoft.office.outlook"
      }
    },
    {
      "mobileAppIdentifier": {
        "@odata.type": "#microsoft.graph.androidMobileAppIdentifier",
        "packageId": "com.microsoft.office.excel"
      }
    }
  ]
}
"@

# Authenticate and post policies
$token = Get-GraphToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret

$uriBase = "https://graph.microsoft.com/beta/deviceAppManagement/managedAppPolicies"

Write-Output "Deploying iOS Managed App Policy..."
Invoke-GraphPost -Uri $uriBase -Token $token -Body $iOSPolicy

Write-Output "Deploying Android Managed App Policy..."
Invoke-GraphPost -Uri $uriBase -Token $token -Body $androidPolicy
