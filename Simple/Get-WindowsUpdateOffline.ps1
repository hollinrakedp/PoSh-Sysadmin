Function Get-WindowsUpdateOffline {
    <#
    .SYNOPSIS
    Get the updates that are installed or missing on the system.

    .DESCRIPTION
    Scans the system for installed Windows updates using the WSUS Scan Offline CAB file (wsusscn2.cab). Gives output of the state of the updates (Installed/Missing).

    The script requires the latest WSUS Scan Offline CAB file (wsusscn2.cab). Download the latest version from here: http://go.microsoft.com/fwlink/p/?LinkID=74689

    .NOTES   
    Name       : Get-WindowsUpdateOffline
    Author     : Darren Hollinrake
    Version    : 1.0
    DateCreated: 2021-07-18
    DateUpdated: 

    .PARAMETER WSUSCABPath
    Specify the location of the wsusscn2.cab file to be used for the scan. The default is "C:\temp\wsusscn2.cab"

    .EXAMPLE
    Scan-UpdatesOffline

    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String]$WSUSCABPath,
        [Parameter()]
        [ValidateSet('Missing', 'Installed', 'Both')]
        [String]$State = "Missing"
    )

    If (!(Test-Path $WSUSCABPath)) {
        Write-Error "Unable to find the wsusscn2.cab"
        exit
    }

    $UpdateSession = New-Object -ComObject Microsoft.Update.Session
    $UpdateServiceManager = New-Object -ComObject Microsoft.Update.ServiceManager
    $UpdateService = $UpdateServiceManager.AddScanPackageService("Offline Sync Service", "$WSUSCABPath", 1)
    $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

    Write-Output "Searching for updates... `r`n"

    $UpdateSearcher.ServerSelection = 3

    $UpdateSearcher.ServiceID = $UpdateService.ServiceID

    switch ($State) {
        Missing { $SearchString = "IsInstalled=0" }
        Installed { $SearchString = "IsInstalled=1" }
        Both { $SearchString = "IsInstalled=0 or IsInstalled=1" } 
    }

    $SearchResult = $UpdateSearcher.Search("$SearchString")

    $Updates = $SearchResult.Updates

    if ($Updates.Count -eq 0) {
        Write-Output "There are no applicable updates."
        return $null
    }

    Write-Output "List of applicable items on the machine when using wssuscan.cab: `r`n"

    $Updates | Select-Object Title, @{Name = "State"; Expression = { switch ($_.IsPresent) {"$true" {"Installed"} "$false" {"Missing"}} } }
}