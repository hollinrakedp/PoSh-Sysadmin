<#
.SYNOPSIS
Set unnecessary services to "Disabled".

.DESCRIPTION
The script changes the startup type to "Disabled" for a list of services. This script has no parameters available.

.NOTES   
Name       : Set-ServicesDisabled.ps1
Author     : Darren Hollinrake
Version    : 1.3
DateCreated: 2018-02-20
DateUpdated: 2020-05-21

v1.3
Commented out "dmwappushservice" and "wlidsvc". When these services are disabled, the first boot after installation is extremely slow.

***Customization***
If additional services need to be disabled, add them to the $Services array.

https://docs.microsoft.com/en-us/windows-server/security/windows-services/security-guidelines-for-disabling-system-services-in-windows-server

MDT Use:
Add to the task sequence during the 'State Restore' portion.

Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Set Services Disabled
PowerShell script: %SCRIPTROOT%\General\Set\Set-ServicesDisabled.ps1

#>

$Services = @("XblAuthManager",
            "XblGameSave",
            "XboxNetApiSvc",
            "xbgm",
            "bthserv",
            "BthHFSrv",
            "lfsvc",
            "Fax",
            "PhoneSvc",
            "icssvc",
            "MapsBroker",
            "WMPNetworkSvc",
            "RetailDemo",
            "RemoteAccess",
            "WalletService",
#            "dmwappushservice",
            "SharedAccess",
            "lltdsvc",
#            "wlidsvc",
            "NcbService",
            "QWAVE",
            "RmSvc",
            "SSDPSRV",
            "FrameServer",
            "ALG",
            "WwanSvc",
            "WlanSvc",
            "AJRouter",
            "MSiSCSI",
            "WpcMonSvc",
            "WFDSConMgrSvc",
            "BTAGService")

# Retrieves the current startup type for the list of services
$ServiceStatus = {Get-Service $Services -ErrorVariable ServiceError | Select-Object @{Name="Service";Expression={$_."DisplayName"}},Name,@{Name="Startup Type";Expression={$_."StartType"}} -Verbose}
# Remove services that don't exist from the array
If ($ServiceError.Count -ne 0){
    Write-Output "The following services did not exist:" ($($ServiceError.Exception.ServiceName) -join ', ')`r`n
    ForEach ($i in $($ServiceError.Exception.ServiceName)) {
        Write-Output "Removing Service from list: $i"
        $Services = $Services | Where-Object {$_ -notin $i}
        }
    }
# Get the current status of the services
Write-Output "`r`nCurrent Status of the Services to be disabled: `r`n========================================================================"
& $ServiceStatus | Out-Host
Write-Output "========================================================================`r`n"
# List the services not already set to 'Disabled' Startup Type
Write-Output "Only the following services will be targeted:"
Get-Service $Services | Where-Object StartType -NE Disabled | Select-Object @{Name="Service Name";Expression={$_."Name"}} | Out-Host
Get-Service $Services | Where-Object StartType -NE Disabled | Stop-Service -PassThru | Set-Service -StartupType Disabled -Verbose


# Using the above method for disabling this service fails with the message: Access denied
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\xbgm"  /f /t REG_DWORD /v Start /d 4

# Get the current status of the services. They should all show disabled.
Write-Output "Post-Script Status of the Services: `r`n========================================================================"
& $ServiceStatus | Out-Host
Write-Output "========================================================================`r`n"
If ((Get-Service $Services | Where-Object StartType -NE Disabled).count -ne 0) {
    Write-Warning "Not all listed services are disabled. Please check the log."
    } Else {
    Write-Output "All services were successfully disabled."
    }

Write-Output ""