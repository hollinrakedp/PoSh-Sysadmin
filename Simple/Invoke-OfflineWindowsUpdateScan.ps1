<#
.SYNOPSIS
Scan the system for missing Microsoft patches.

.DESCRIPTION
The script can be used to scan the local system for missing Microsoft patches.

The script requires the latest WSUS Scan Offline CAB file (wsusscn2.cab). Download the latest version from here: http://go.microsoft.com/fwlink/p/?LinkID=74689

.NOTES   
Name       : Invoke-OfflineWindowsUpdateScan.ps1
Author     : Darren Hollinrake
Version    : 0.2
DateCreated: 2018-11-05
DateUpdated: 2022-05-07

.PARAMETER Path
Specify the location of the wsusscn.cab file to be used for the scan. The default is "C:\temp\wsusscn2.cab"

.LINK
http://go.microsoft.com/fwlink/p/?LinkID=74689

.EXAMPLE
.\Invoke-OfflineWindowsUpdateScan.ps1 -Path "C:\temp\wsusscn2.cab"

#>

#Requires -RunAsAdministrator
[CmdletBinding()]

Param(
    [Parameter()]
    [string]$Path = "C:\temp\wsusscn2.cab"
)


$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateServiceManager = New-Object -ComObject Microsoft.Update.ServiceManager
$UpdateService = $UpdateServiceManager.AddScanPackageService("Offline Sync Service", "$Path", 1)
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

Write-Output "Searching for updates... `r`n"

$UpdateSearcher.ServerSelection = 3 #ssOthers
$UpdateSearcher.ServiceID = $UpdateService.ServiceID

$SearchResult = $UpdateSearcher.Search("IsInstalled=0") # Change to "IsInstalled=0 and IsInstalled=1" to list the needed and installed updates as the MBSA did.
$Updates = $SearchResult.Updates

if ($Updates.Count -eq 0) {
    Write-Output "There are no applicable updates."
    return $null
}

Write-Output "List of applicable items on the machine when using wssuscan.cab: `r`n"

$i = 1
foreach ($Update in $Updates) {
    Write-Output "$($i)> $($Update.Title)"
    $i++
}