function Scan-WindowsUpdateOffline {
    <#
    .SYNOPSIS
    Scan a stand-alone/isolated/air-gapped Windows system for needed updates.

    .DESCRIPTION
    This script will allow you to scan a Windows system that is stand-alone/isolated/air-gapped to find needed patches that need to be installed. It leverages the Windows Update Agent (WUA) and the Windows Update offline scan file (wsusscn2.cab) to determine what updates are applicable to a system.

    Ensure the wsusscn2.cab file has been downloaded. The latest version can be found here: https://go.microsoft.com/fwlink/?linkid=74689

    .PARAMETER Path
    The path to the scan file to be used. The default is to use 'C:\Temp' and the original name of the file 'wsusscn2.cab'. If the file is in a different location or has a different name, specify the full path to the file.

    .PARAMETER OutputPath
    Optional path to export the results. Supports CSV and TXT formats based on file extension. If not specified, results are only displayed on console.

    .PARAMETER ScanType
    Specifies what type of updates to scan for. Valid values are:
    - Needed: Only show updates that are not installed (default)
    - Installed: Only show updates that are already installed
    - Both: Show all applicable updates regardless of installation status

    .PARAMETER Force
    Forces overwrite of existing output file without prompting.

    .EXAMPLE
    Scan-WindowsUpdateOffline

    .EXAMPLE
    Scan-WindowsUpdateOffline -Path "D:\Updates\wsusscn2.cab" -OutputPath "C:\Reports\NeededUpdates.csv"

    .EXAMPLE
    Scan-WindowsUpdateOffline -ScanType Installed -OutputPath "C:\Reports\InstalledUpdates.csv"

    .EXAMPLE
    Scan-WindowsUpdateOffline -ScanType Both -OutputPath "C:\Reports\AllUpdates.csv"

    .LINK
    https://go.microsoft.com/fwlink/?linkid=74689

    #>
    [CmdletBinding()]
    param(
        [Parameter(HelpMessage = "Path to the wsusscn2.cab scan file")]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path = "C:\Temp\wsusscn2.cab",
    
        [Parameter(HelpMessage = "Optional path to export results (CSV or TXT format)")]
        [ValidatePattern('\.(csv|txt)$')]
        [string]$OutputPath,
    
        [Parameter(HelpMessage = "Specify what type of updates to scan for: Needed, Installed, or Both")]
        [ValidateSet("Needed", "Installed", "Both")]
        [string]$ScanType = "Needed",
    
        [Parameter(HelpMessage = "Forces overwrite of existing output file without prompting")]
        [switch]$Force
    )

    # Administrator Check
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Scanning for updates requires administrative privileges. Rerun with elevated rights."
    }

    if (!(Test-Path -Path $Path -PathType Leaf)) {
        Write-Error "The path provided needs to point to the cab file."
    }

    # Stop if the output file exists and Force is not specified
    if ($OutputPath -and (Test-Path -Path $OutputPath) -and -not $Force) {
        Write-Error "Output file '$OutputPath' already exists. Use the '-Force' parameter to overwrite."
        return
    }

    Write-Host ""
    Write-Host "$("=" * 38)" -ForegroundColor Magenta
    Write-Host "    Windows Offline Update Scanner" -ForegroundColor White
    Write-Host "$("=" * 38)" -ForegroundColor Magenta
    Write-Host "Scan File: " -NoNewline -ForegroundColor Gray
    Write-Host $Path -ForegroundColor White
    Write-Host "Scan Type: " -NoNewline -ForegroundColor Gray
    Write-Host $ScanType -ForegroundColor White
    Write-Host "Date/Time: " -NoNewline -ForegroundColor Gray
    Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -ForegroundColor White
    Write-Host ""

    $UpdateSession = New-Object -ComObject Microsoft.Update.Session
    $UpdateServiceManager = New-Object -ComObject Microsoft.Update.ServiceManager
    $UpdateService = $UpdateServiceManager.AddScanPackageService("Offline Sync Service", "$Path", 1)
    $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
    $UpdateSearcher.ServerSelection = 3
    $UpdateSearcher.ServiceID = "$($UpdateService.ServiceID )"

    # Determine search criteria based on ScanType parameter
    $SearchCriteria = switch ($ScanType) {
        "Needed" { "IsInstalled=0" }
        "Installed" { "IsInstalled=1" }
        "Both" { "IsInstalled=0 or IsInstalled=1" }
    }

    $SearchMessage = switch ($ScanType) {
        "Needed" { "Searching for needed updates..." }
        "Installed" { "Searching for installed updates..." }
        "Both" { "Searching for all applicable updates..." }
    }

    Write-Host "$SearchMessage `r`n" -ForegroundColor Cyan

    $SearchResult = $UpdateSearcher.Search($SearchCriteria)
    $Updates = $SearchResult.Updates

    $UpdateResults = @()

    if ($Updates.Count -eq 0) {
        Write-Host "There are no applicable updates." -ForegroundColor Green
    }
    else {
        Write-Host "Found $($Updates.Count) applicable updates`r`n" -ForegroundColor Yellow
        $i = 0
        foreach ($Update in $Updates) {
            $UpdateResult = [PSCustomObject]@{
                KB                 = ($Update.KBArticleIDs -join ", ")
                InstallationStatus = if ($Update.IsInstalled) { "Installed" } else { "Needed" }
                Title              = $Update.Title
                Description        = $Update.Description
            }
            $UpdateResults += $UpdateResult
            $i++
        }
    }

    # Export results if OutputPath is specified
    if ($OutputPath) {
        Write-Host "Results will be exported to: $OutputPath" -ForegroundColor Green
        try {
            $OutputDir = Split-Path -Path $OutputPath -Parent
            if ($OutputDir -and !(Test-Path -Path $OutputDir)) {
                New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
            }
        
            $Extension = [System.IO.Path]::GetExtension($OutputPath).ToLower()
        
            if ($Extension -eq ".csv") {
                $UpdateResults | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
            }
            elseif ($Extension -eq ".txt") {
                $TextOutput = @()
                $TextOutput += "Windows Update Scan Results - $(Get-Date)"
                $TextOutput += "Scan File: $Path"
                $TextOutput += "Scan Type: $ScanType"
                $TextOutput += "Total Updates Found: $($Updates.Count)"
                $TextOutput += "-" * 50
            
                if ($Updates.Count -eq 0) {
                    $TextOutput += "No applicable updates found."
                }
                else {
                    foreach ($Result in $UpdateResults) {
                        if ($Result.KB) { $TextOutput += "   KB Article: $($Result.KB)" }
                        if ($Result.InstallationStatus) { $TextOutput += "   Status: $($Result.InstallationStatus)" }
                        $TextOutput += "   $($Result.Title)"
                        if ($Result.Description) { $TextOutput += "   Description: $($Result.Description)" }
                        $TextOutput += ""
                    }
                }
            
                $TextOutput | Out-File -FilePath $OutputPath -Encoding UTF8
            }
        }
        catch {
            Write-Warning "Failed to export results: $($_.Exception.Message)"
        }
    }

    $UpdateResults
}
