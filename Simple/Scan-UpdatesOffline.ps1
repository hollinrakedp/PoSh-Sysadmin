<#
.SYNOPSIS
Scan the system for missing Microsoft patches.

.DESCRIPTION
The script can be used to scan the local system for missing Microsoft patches.

The script requires the latest WSUS Scan Offline CAB file (wsusscn2.cab). Download the latest version from here: http://go.microsoft.com/fwlink/p/?LinkID=74689

.NOTES   
Name       : Scan-UpdateOffline.ps1
Author     : Darren Hollinrake
Version    : 0.1
DateCreated: 2018-11-05
DateUpdated: 

.PARAMETER ScanFilePath
Specify the location of the wsusscn.cab file to be used for the scan. The default is "C:\temp\wsusscn2.cab"

.EXAMPLE
Clear-EventLog

#>

#Requires -RunAsAdministrator
[CmdletBinding()]

Param(
    [Parameter()]
    [string]$ScanFilePath = "C:\temp\wsusscn2.cab",
    [Parameter()]
    [switch]$scheduletask,
    [Parameter()]
    [switch]$removetask
)

########################
#      Variables       #
########################
#region Variables
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateServiceManager  = New-Object -ComObject Microsoft.Update.ServiceManager
$UpdateService = $UpdateServiceManager.AddScanPackageService("Offline Sync Service", "$ScanFilePath", 1)
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
#endregion Variables

Write-Output "Searching for updates... `r`n"

$UpdateSearcher.ServerSelection = 3 #ssOthers

$UpdateSearcher.ServiceID = $UpdateService.ServiceID

$SearchResult = $UpdateSearcher.Search("IsInstalled=0") # or "IsInstalled=0 and IsInstalled=1" to also list the installed updates as MBSA did

$Updates = $SearchResult.Updates

if($Updates.Count -eq 0){
    Write-Output "There are no applicable updates."
    return $null
}

Write-Output "List of applicable items on the machine when using wssuscan.cab: `r`n"

$i = 1
foreach($Update in $Updates){
    Write-Output "$($i)> $($Update.Title)"
    $i++
}