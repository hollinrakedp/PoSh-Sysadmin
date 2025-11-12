# UNCLASSIFIED
function Get-DisaFiles {
    <#
    .SYNOPSIS
    Downloads DISA STIG files from the public.cyber.mil website and enhanced benchmarks from NIWC Atlantic's GitHub repo.

    .DESCRIPTION
    This function downloads DISA STIG files from the public.cyber.mil website and enhanced benchmarks from NIWC Atlantic's GitHub repo. This function requires the Selenium PowerShell module, Chrome Browser, and Chrome WebDriver.

    For DISA files, the function uses Selenium WebDriver with Chrome to execute JavaScript and extract download links from the modern DISA website.

    Enhanced benchmarks are downloaded directly from the NIWC Atlantic GitHub repository.

    To use this function
        Install the Selenium PowerShell module.
            Install-Module -Name Selenium

        Download Chrome (headless) and Chrome Driver. These need to be a matching pair.
            You can use the parameter '-DownloadChrome' to automatically download the necessary files.

        Dot source this file and run the function as found in the first example.

    .NOTES
    Name         - Get-DisaFiles
    Version      - 2.11
    Author       - Darren Hollinrake
    Date Created - 2024-09-27
    Date Updated - 2025-11-11

    Requirements:
    - Selenium PowerShell module (Install-Module Selenium)
    - Chrome browser (headless) and ChromeDriver (Download automatically using parameter '-DownloadChrome')

    .PARAMETER Destination
    The destination folder where the files will be downloaded. Additional folders will be created using this as the root directory.

    Folder structure:
        $Destination
        ├───Automation
        ├───Benchmark
        ├───Enhanced Benchmark
        ├───GPO
        │   └───YYYY-MM
        ├───SCC
        │   └───X.X.X
        ├───STIG
        ├───STIG Library
        │   └───YYYY-MM
        └───STIG Viewer
            └───X.X.X

    .PARAMETER Benchmark
    Downloads the standard benchmark files.

    .PARAMETER EnhancedBenchmark
    Downloads the individual enhanced benchmark files provided by NIWC Atlantic.

    .PARAMETER GPO
    Downloads the DISA GPO files. Files are automatically organized into dated subfolders (YYYY-MM format) based on the release date extracted from filenames.

    .PARAMETER SCC
    Downloads the SCAP Compliance Checker (SCC) installation files. Files are automatically organized into versioned subfolders (X.X.X format) based on the version number extracted from filenames.

    .PARAMETER STIG
    Downloads the individual STIG and SRG files.

    .PARAMETER STIGLibrary
    Downloads the SRG-STIG Library compilation file containing all STIGs and SRGs. Files are automatically organized into dated subfolders (YYYY-MM format) based on the release date extracted from filenames.

    .PARAMETER StigViewer
    Downloads the STIG Viewer files. Files are automatically organized into versioned subfolders (X.X.X format) based on the version number extracted from filenames. User guide PDFs are placed in the corresponding version folder when downloaded together.

    .PARAMETER Automation
    Downloads the automation implementation files (Chef, Ansible, PowerShell DSC).

    .PARAMETER BinaryPath
    The path to the Chrome binary (chrome.exe or chrome-headless-shell.exe). If not specified, uses the default Chrome installation.

    .PARAMETER WebDriverDirectory
    The directory containing the ChromeDriver executable. If not specified, assumes ChromeDriver is in the system PATH.

    .PARAMETER DownloadChrome
    This specifies to download Chrome and compatible driver.

    .PARAMETER ChromePath
    The path to which the Chrome files will be downloaded and extracted to. The default is 'C:\Temp\Chrome'

    .PARAMETER CleanupChrome
    When used with -DownloadChrome, automatically removes the downloaded Chrome files after the function completes. Only available when using the DownloadChrome parameter set.

    .PARAMETER ForceDownload
    When used with -DownloadChrome, forces re-download of Chrome and ChromeDriver even if they already exist at the target location. Useful for updating to the latest version.

    .EXAMPLE
    Get-DisaFiles -Destination "C:\Temp\DISA" -DownloadChrome

    Downloads Chrome and Chrome drivers and places in them in the default location (C:\temp\Chrome).
    Once complete, it downloads all available Benchmarks, Enhanced Benchmarks, GPO packages, SCC versions, STIGs/SRGs, STIG Viewer versions.
    If Chrome already exists, it will skip the download.

    .EXAMPLE
    Get-DisaFiles -Destination "C:\Temp\DISA" -Benchmark -GPO -DownloadChrome -CleanupChrome

    Downloads Chrome/Driver, downloads only the benchmark and GPO files, then cleans up the Chrome files afterward.

    .EXAMPLE
    Get-DisaFiles -Destination "C:\Temp\DISA" -DownloadChrome -ForceDownload

    Forces re-download of Chrome and ChromeDriver to get the latest version, even if they already exist.

    .EXAMPLE
    Get-DisaFiles -Destination "C:\Temp\DISA" -BinaryPath "C:\Temp\Chrome\chrome-headless-shell-win64\chrome-headless-shell.exe" -WebDriverDirectory "C:\Temp\Chrome\chromedriver-win64"

    Downloads all files using a custom Chrome binary and ChromeDriver location.

    .LINK
        https://public.cyber.mil/stigs/downloads
        https://www.niwcatlantic.navy.mil/Technology/SCAP/SCAP-Content-Repository
        https://github.com/niwc-atlantic/scap-content-library
        https://developer.chrome.com/docs/chromedriver/downloads

    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ExistingChrome')]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory, ParameterSetName = 'ExistingChrome')]
        [Parameter(ValueFromPipelineByPropertyName, Mandatory, ParameterSetName = 'DownloadChrome')]
        [Alias('Path')]
        [string]$Destination,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ExistingChrome')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$Benchmark,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ExistingChrome')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$EnhancedBenchmark,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ExistingChrome')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$GPO,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ExistingChrome')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$SCC,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ExistingChrome')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$STIG,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ExistingChrome')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$STIGLibrary,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ExistingChrome')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$StigViewer,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ExistingChrome')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$Automation,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ExistingChrome')]
        [string]$BinaryPath,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ExistingChrome')]
        [string]$WebDriverDirectory,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$DownloadChrome,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [string]$ChromePath = "C:\Temp\Chrome",

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$CleanupChrome,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DownloadChrome')]
        [switch]$ForceDownload
    )

    begin {
        $Data = @()
        $EnhancedData = @()

        try {
            Import-Module Selenium -ErrorAction Stop

            if ($DownloadChrome) {
                Write-Host "`nChecking Chrome installation..." -ForegroundColor Cyan

                # Paths for Chrome and ChromeDriver
                $ExpectedBinaryPath = Join-Path -Path $ChromePath -ChildPath "chrome-headless-shell-win64\chrome-headless-shell.exe"
                $ExpectedWebDriverDirectory = Join-Path -Path $ChromePath -ChildPath "chromedriver-win64"
                $ExpectedDriverPath = Join-Path -Path $ExpectedWebDriverDirectory -ChildPath "chromedriver.exe"

                # Check if Chrome and ChromeDriver already exist
                if ((Test-Path $ExpectedBinaryPath) -and (Test-Path $ExpectedDriverPath) -and !$ForceDownload) {
                    Write-Host "Chrome and ChromeDriver already found at: $ChromePath" -ForegroundColor Green
                    Write-Host "Skipping download and using existing installation" -ForegroundColor Green
                    $BinaryPath = $ExpectedBinaryPath
                    $WebDriverDirectory = $ExpectedWebDriverDirectory
                }
                else {
                    if ($ForceDownload) {
                        Write-Host "Force download specified. Re-downloading Chrome and ChromeDriver..." -ForegroundColor Yellow
                    }
                    else {
                        Write-Host "Chrome not found or incomplete. Downloading Chrome and ChromeDriver..." -ForegroundColor Yellow
                    }
                    $JsonUrl = "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"

                    if (! (Test-Path -Path $ChromePath)) {
                        Write-Host "Creating Chrome Path: $ChromePath" -ForegroundColor Cyan
                        New-Item -ItemType Directory -Path $ChromePath -Force | Out-Null
                    }

                    Write-Host "Fetching Chrome versions from JSON..." -ForegroundColor Cyan
                    $ChromeData = Invoke-RestMethod -Uri $JsonUrl

                    # Get the last (latest) version entry
                    $Latest = $ChromeData.versions[-1]
                    $Version = $Latest.version
                    Write-Host "Latest Chrome version: $Version" -ForegroundColor Green

                    $ChromeUrl = ($Latest.downloads.'chrome-headless-shell' | Where-Object { $_.platform -eq "win64" }).url
                    $DriverUrl = ($Latest.downloads.chromedriver | Where-Object { $_.platform -eq "win64" }).url

                    Write-Verbose "Headless Chrome URL: $ChromeUrl"
                    Write-Verbose "Driver URL: $DriverUrl"

                    $ChromeZip = Join-Path -Path $ChromePath -ChildPath "chrome-headless-$Version.zip"
                    $DriverZip = Join-Path -Path $ChromePath -ChildPath "chromedriver-$Version.zip"

                    # Download & Extract
                    Write-Host "Downloading Chrome headless shell..." -ForegroundColor Cyan
                    Invoke-WebRequest -Uri $ChromeUrl -OutFile $ChromeZip
                    Write-Host "Downloading ChromeDriver..." -ForegroundColor Cyan
                    Invoke-WebRequest -Uri $driverUrl -OutFile $DriverZip

                    Write-Host "Extracting Chrome files..." -ForegroundColor Cyan
                    Expand-Archive -Path $ChromeZip -DestinationPath $ChromePath -Force
                    Expand-Archive -Path $DriverZip -DestinationPath $ChromePath -Force

                    Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
                    Remove-Item $ChromeZip, $DriverZip

                    $BinaryPath = Join-Path -Path $ChromePath -ChildPath "chrome-headless-shell-win64\chrome-headless-shell.exe"
                    $WebDriverDirectory = Join-Path -Path $ChromePath -ChildPath "chromedriver-win64"

                    Write-Host "Chrome setup completed successfully!" -ForegroundColor Green
                }
            }

            Write-Host "Attempting to retrieve DISA file list..." -ForegroundColor Cyan

            $Driver = $null
            try {
                # Build Chrome startup parameters
                $ChromeParams = @{
                    StartURL = "https://public.cyber.mil/stigs/downloads"
                    Headless = $true
                }

                # Add BinaryPath if specified
                if ($BinaryPath) {
                    if (!(Test-Path $BinaryPath)) {
                        throw "Chrome binary not found: $BinaryPath"
                    }
                    $ChromeParams.BinaryPath = $BinaryPath
                }

                # Add WebDriverDirectory if specified
                if ($WebDriverDirectory) {
                    if (!(Test-Path $WebDriverDirectory)) {
                        throw "ChromeDriver directory not found: $WebDriverDirectory"
                    }
                    $ChromeParams.WebDriverDirectory = $WebDriverDirectory
                }

                Write-Verbose "Starting Chrome WebDriver with parameters: $($ChromeParams | ConvertTo-Json -Compress)"
                $Driver = Start-SeChrome @ChromeParams

                $null = $Driver.Title
                Write-Verbose "Chrome WebDriver started successfully"

                Write-Host "Waiting for page to load..." -ForegroundColor Cyan
                Start-Sleep -Seconds 1

                # Extract download links from current page
                function Get-DownloadLinksFromCurrentPage {
                    param($WebDriver)

                    $PageData = @()
                    $DataLinkElements = $WebDriver.FindElementsByXPath("//*[@data-link]")

                    foreach ($element in $DataLinkElements) {
                        try {
                            $dataLink = $element.GetAttribute("data-link")
                            if ($dataLink -and $dataLink -match "^https?://") {
                                $PageData += $dataLink
                                Write-Verbose "Found download link: $dataLink"
                            }
                        }
                        catch {
                            Write-Verbose "Could not extract data-link from element: $_"
                        }
                    }
                    return $PageData
                }

                # Function to wait for page to load completely
                function Wait-ForPageLoad {
                    param(
                        $WebDriver,
                        [int]$TimeoutSeconds = 2
                    )

                    Write-Verbose "Waiting briefly for content to update..."
                    Start-Sleep -Milliseconds 40
                    return $true
                }

                # Function to find and click the next page button
                function Find-AndClickNextButton {
                    param(
                        $WebDriver,
                        [int]$PageNumber
                    )

                    Write-Verbose "Looking for single page forward button on page $PageNumber..."

                    try {
                        Write-Verbose "Looking for chevronright forward button..."
                        $AllChevronButtons = $WebDriver.FindElementsByXPath("//*[contains(@data-key, 'chevronright')]//ancestor::button[1] | //button[.//*[contains(@data-key, 'chevronright')]]")

                        foreach ($button in $AllChevronButtons) {
                            try {
                                if ($button.Enabled -and $button.Displayed) {
                                    Write-Debug "Found chevron forward button..."
                                    return Invoke-ButtonClick -WebDriver $WebDriver -Button $button -ButtonType "Chevron Forward"
                                }
                            }
                            catch {
                                Write-Verbose "Error checking chevron button: $_"
                            }
                        }
                    }
                    catch {
                        Write-Verbose "Chevron search failed: $_"
                    }

                    Write-Verbose "No single page forward buttons found - likely at end of pages"
                    return $false
                }

                function Invoke-ButtonClick {
                    param(
                        $WebDriver,
                        $Button,
                        [string]$ButtonType = "Unknown"
                    )

                    try {
                        # Click the next/forward button
                        Write-Verbose "Attempting click on $ButtonType button..."
                        $WebDriver.ExecuteScript("arguments[0].click();", $Button)

                        Start-Sleep -Milliseconds 40

                        Write-Verbose "Successfully clicked $ButtonType button"
                        return $true
                    }
                    catch {
                        Write-Warning "Click failed for $ButtonType button: $_"
                        return $false
                    }
                }

                # Handle pagination and collect all download links
                function Get-AllDownloadLinks {
                    param($WebDriver)

                    $AllData = @()
                    $PageNumber = 1
                    $MaxPages = 100
                    $ConsecutiveFailures = 0
                    $MaxConsecutiveFailures = 3
                    $ConsecutiveEmptyPages = 0
                    $MaxConsecutiveEmptyPages = 2

                    Write-Host "Starting pagination scan..." -ForegroundColor Cyan

                    try {
                        do {
                            Write-Host "Scanning page $PageNumber for download links..." -ForegroundColor Cyan

                            # Wait for page content to load completely
                            $PageLoadSuccess = Wait-ForPageLoad -WebDriver $WebDriver -TimeoutSeconds 15
                            if (-not $PageLoadSuccess) {
                                Write-Warning "Page $PageNumber did not load completely within timeout"
                            }

                            # Additional wait for dynamic content
                            Start-Sleep -Milliseconds 50

                            # Get links from current page
                            try {
                                $CurrentPageData = Get-DownloadLinksFromCurrentPage -WebDriver $WebDriver

                                if ($CurrentPageData.Count -gt 0) {
                                    $AllData = $AllData + $CurrentPageData
                                    $ConsecutiveFailures = 0
                                    $ConsecutiveEmptyPages = 0
                                    Write-Host "Found $($CurrentPageData.Count) links on page $PageNumber (Total: $($AllData.Count))" -ForegroundColor Green
                                }
                                else {
                                    $ConsecutiveEmptyPages++
                                    Write-Host "No links found on page $PageNumber (consecutive empty: $ConsecutiveEmptyPages)" -ForegroundColor Yellow

                                    # End of pages
                                    if ($ConsecutiveEmptyPages -ge $MaxConsecutiveEmptyPages) {
                                        Write-Host "Multiple consecutive empty pages detected. Likely reached end of content." -ForegroundColor Yellow
                                        break
                                    }
                                }
                            }
                            catch {
                                $ConsecutiveFailures++
                                Write-Warning "Failed to extract data from page $PageNumber : $($_.Exception.Message)"

                                if ($ConsecutiveFailures -ge $MaxConsecutiveFailures) {
                                    Write-Warning "Too many consecutive failures. Stopping pagination scan."
                                    break
                                }
                            }

                            # Try to navigate to next page
                            Write-Verbose "Attempting to navigate from page $PageNumber to next page..."
                            $NextPageFound = Find-AndClickNextButton -WebDriver $WebDriver -PageNumber $PageNumber

                            if ($NextPageFound) {
                                Write-Verbose "Navigation successful. Waiting for content to update..."
                                $null = Wait-ForPageLoad -WebDriver $WebDriver
                                $PageNumber++
                                Write-Verbose "Successfully moved to page $PageNumber"
                            }
                            else {
                                Write-Host "No more pages available. Pagination scan complete." -ForegroundColor Green
                                break
                            }

                        } while ($PageNumber -le $MaxPages)

                        # Check max pages limit
                        if ($PageNumber -gt $MaxPages) {
                            Write-Warning "Reached maximum page limit ($MaxPages). There may be more content available."
                        }
                    }
                    catch {
                        Write-Warning "Critical error during pagination: $($_.Exception.Message)"
                        Write-Warning "Stack trace: $($_.ScriptStackTrace)"
                        Write-Warning "Continuing with data collected so far..."
                    }

                    # Pagination Results
                    Write-Verbose "`n$("="*50)"
                    Write-Verbose "PAGINATION SCAN RESULTS"
                    Write-Verbose "$("="*50)"
                    Write-Verbose "Pages scanned: $PageNumber"
                    Write-Verbose "Total unique links found: $($AllData.Count)"
                    Write-Verbose "Consecutive failures: $ConsecutiveFailures"
                    Write-Verbose "Consecutive empty pages: $ConsecutiveEmptyPages"
                    Write-Verbose "$("="*50)"

                    if ($AllData.Count -eq 0) {
                        Write-Warning "No download links were found during pagination scan."
                        Write-Warning "This may indicate:"
                        Write-Warning "  1. A website structure change"
                        Write-Warning "  2. Network connectivity issues"
                        Write-Warning "  3. Website access restrictions"
                        Write-Warning "  4. Updated Lightning Web Component selectors needed"
                    }
                    else {
                        Write-Host "Pagination scan completed successfully!" -ForegroundColor Green
                    }

                    return $AllData
                }

                $AllPageData = Get-AllDownloadLinks -WebDriver $Driver
                $Data = $AllPageData | Sort-Object -Unique
                Write-Host "Successfully extracted $($Data.Count) unique download links from all pages" -ForegroundColor Green
            }
            finally {
                if ($Driver) {
                    $Driver.Quit()
                    $Driver.Dispose()
                }
            }
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Warning "Unable to retrieve DISA file list using Selenium: $ErrorMessage"

            # Provide guidance based on error
            if ($ErrorMessage -match "cannot find Chrome binary|chrome.*not found") {
                Write-Warning "Chrome browser not found. Consider using -DownloadChrome parameter or specify -BinaryPath."
            }
            elseif ($ErrorMessage -match "chromedriver|driver.*not found") {
                Write-Warning "ChromeDriver not found. Consider using -DownloadChrome parameter or specify -WebDriverDirectory."
            }
            elseif ($ErrorMessage -match "version|compatibility") {
                Write-Warning "Chrome and ChromeDriver version mismatch. Ensure compatible versions are installed."
            }
            else {
                Write-Warning "General Selenium error. Verify Chrome, ChromeDriver, and Selenium module are properly installed."
            }

            Write-Warning "You may need to download files manually from https://public.cyber.mil/stigs/downloads"
        }

        Write-Host "`nRetrieving Enhanced Benchmarks from NIWC Atlantic..." -ForegroundColor Cyan
        try {
            $EnhancedData = (Invoke-WebRequest -Uri "https://github.com/niwc-atlantic/scap-content-library" -TimeoutSec 60).Links.href
            $EnhancedBenchmarkCount = ($EnhancedData | Where-Object { $_ -match 'Benchmark.*\.zip$' }).Count
            Write-Host "Found $EnhancedBenchmarkCount Enhanced Benchmark files" -ForegroundColor Green
        }
        catch {
            Write-Warning "Unable to retrieve enhanced file list: $_"
            Write-Warning "Enhanced benchmarks will not be available"
            $EnhancedData = @()
        }
    }

    process {
        $DestinationPaths = @{
            Automation        = Join-Path -Path $Destination -ChildPath "Automation"
            Benchmark         = Join-Path -Path $Destination -ChildPath "Benchmark"
            EnhancedBenchmark = Join-Path -Path $Destination -ChildPath "Enhanced Benchmark"
            GPO               = Join-Path -Path $Destination -ChildPath "GPO"
            SCC               = Join-Path -Path $Destination -ChildPath "SCC"
            STIG              = Join-Path -Path $Destination -ChildPath "STIG"
            STIGLibrary       = Join-Path -Path $Destination -ChildPath "STIG Library"
            StigViewer        = Join-Path -Path $Destination -ChildPath "STIG Viewer"
        }

        # Default to download all content if no download parameter is selected
        $DownloadSwitches = @('Automation', 'Benchmark', 'EnhancedBenchmark', 'GPO', 'SCC', 'STIG', 'STIGLibrary', 'StigViewer')
        if (-not ($PSBoundParameters.Keys | Where-Object { $DownloadSwitches -contains $_ })) {
            Write-Host "No specific download switches provided. Defaulting to download all types."
            foreach ($Switch in $DownloadSwitches) {
                $PSBoundParameters[$switch] = $true
            }
        }

        # Create Required Sub-Directories
        $PSBoundParameters.Keys | Where-Object { $DownloadSwitches -contains $_ } | ForEach-Object {
            $Path = $DestinationPaths[$_]
            if (!(Test-Path $Path)) {
                Write-Host "Creating directory: $Path"
                New-Item -Path $Path -ItemType Directory -Force -WhatIf:$WhatIfPreference | Out-Null
            }
        }

        $Downloads = @()

        foreach ($Switch in $PSBoundParameters.Keys) {
            $Links = @()
            switch ($Switch) {
                'Automation' {
                    $Links = $Data | Where-Object {
                        $_ -match '_Chef\.zip$|_Ansible\.zip$|_DSC\.zip$' -and $_ -notmatch 'Benchmark|GPO|SCC|STIGViewer|STIG.*Viewer'
                    }
                }
                'Benchmark' {
                    $Links = $Data | Where-Object {
                        $_ -match 'Benchmark.*\.zip'
                    }
                }
                'EnhancedBenchmark' {
                    $Links = $EnhancedData | Where-Object { $_ -match 'Benchmark.*\.zip$' }
                }
                'GPO' {
                    $Links = $Data | Where-Object {
                        $_ -match 'STIG.*GPO.*Package.*\.zip|GPO.*Package.*\.zip'
                    }
                }
                'SCC' {
                    $Links = $Data | Where-Object {
                        $_ -match 'SCC|SCAP.*Compliance.*Checker'
                    }
                }
                'STIG' {
                    $Links = $Data | Where-Object {
                        $_ -match '_STIG\.zip$|_SRG\.zip$' -and $_ -notmatch 'Benchmark|GPO|SCC|STIGViewer|STIG.*Viewer|SRG-STIG.*Library'
                    }
                }
                'STIGLibrary' {
                    $Links = $Data | Where-Object {
                        $_ -match 'SRG-STIG.*Library.*\.zip'
                    }
                }
                'StigViewer' {
                    $Links = $Data | Where-Object {
                        $_ -match 'STIGViewer|STIG.*Viewer'
                    }
                }
            }

            if ($Links) {
                $Links | ForEach-Object {
                    $Downloads += [PSCustomObject]@{
                        Uri     = $_
                        OutFile = $DestinationPaths[$Switch]
                    }
                }
            }
        }

        $Failure = 0
        $Success = 0
        $Skipped = 0
        $StartTime = Get-Date

        # Progress Reporting
        $TotalFiles = $Downloads.Count
        if ($TotalFiles -gt 0) {
            Write-Output "Starting download of $TotalFiles files..."
        }

        $Downloads | ForEach-Object -Begin {
            $CurrentFile = 0
        } -Process {
            $CurrentFile++
            $FileName = ($_.Uri -split '/')[-1] -replace '\?.*', ''

            # Update Progress
            if ($TotalFiles -gt 1) {
                $PercentComplete = [math]::Round(($CurrentFile / $TotalFiles) * 100)
                Write-Progress -Activity "Downloading DISA Files" -Status "File $CurrentFile of $TotalFiles - $FileName" -PercentComplete $PercentComplete
            }

            if ($PSCmdlet.ShouldProcess("$FileName", "Download File")) {
                $TargetDownloadPath = $PSItem.OutFile

                # Handle GPO and STIG Library files with dated subfolders
                if (($FileName -match 'GPO.*Package.*\.zip' -or $FileName -match 'SRG-STIG.*Library.*\.zip') -and $FileName -match '_([A-Za-z]+)_(\d{4})\.zip') {
                    $MonthName = $Matches[1]
                    $Year = $Matches[2]
                    $FileType = if ($FileName -match 'GPO.*Package') { "GPO" } else { "STIG Library" }

                    # Convert month name to number
                    try {
                        $MonthNumber = [DateTime]::ParseExact($MonthName, 'MMMM', [System.Globalization.CultureInfo]::InvariantCulture).ToString('MM')
                        $DateFolder = "$Year-$MonthNumber"
                        $TargetDownloadPath = Join-Path -Path $PSItem.OutFile -ChildPath $DateFolder

                        # Create the dated subfolder
                        if (!(Test-Path $TargetDownloadPath)) {
                            Write-Host "Creating $FileType date folder: $DateFolder" -ForegroundColor Cyan
                            New-Item -Path $TargetDownloadPath -ItemType Directory -Force -WhatIf:$WhatIfPreference | Out-Null
                        }
                    }
                    catch {
                        Write-Warning "Could not parse month '$MonthName' from $FileType file '$FileName'. Using default folder."
                        # Fall back to original path if date parsing fails
                    }
                }
                # Handle SCC files with versioned subfolders
                elseif ($FileName -match '^[Ss][Cc][Cc].*(\d+\.\d+\.\d+)' -or $FileName -match '^RPM-GPG-KEY-SCC-(\d+\.\d+\.\d+)') {
                    $Version = $Matches[1]
                    $FileType = "SCC"

                    try {
                        $VersionFolder = $Version
                        $TargetDownloadPath = Join-Path -Path $PSItem.OutFile -ChildPath $VersionFolder

                        # Create the versioned subfolder
                        if (!(Test-Path $TargetDownloadPath)) {
                            Write-Host "Creating $FileType version folder: $VersionFolder" -ForegroundColor Cyan
                            New-Item -Path $TargetDownloadPath -ItemType Directory -Force -WhatIf:$WhatIfPreference | Out-Null
                        }
                    }
                    catch {
                        Write-Warning "Could not parse version '$Version' from $FileType file '$FileName'. Using default folder."
                        # Fall back to original path if version parsing fails
                    }
                }
                # Handle STIG Viewer files with versioned subfolders
                elseif ($FileName -match '^U_STIGViewer[_-](\d+-\d+)(?:[_\.]|$)' -or $FileName -match '^U_STIGViewer[_-](\d+-\d+-\d+)[_\.]' -or $FileName -match '^U_STIGViewer.*-(\d+-\d+-\d+)[\._]') {
                    $VersionRaw = $Matches[1]
                    $FileType = "STIG Viewer"

                    try {
                        # Convert version format to standard dotted notation
                        if ($VersionRaw -match '^\d+-\d+$') {
                            # Handle 2-18 pattern (convert to 2.18)
                            $VersionFolder = $VersionRaw -replace '-', '.'
                        }
                        elseif ($VersionRaw -match '^\d+-\d+-\d+$') {
                            # Handle 3-6-0 pattern (convert to 3.6.0)
                            $VersionFolder = $VersionRaw -replace '-', '.'
                        }
                        else {
                            $VersionFolder = $VersionRaw
                        }

                        $TargetDownloadPath = Join-Path -Path $PSItem.OutFile -ChildPath $VersionFolder

                        # Create the versioned subfolder
                        if (!(Test-Path $TargetDownloadPath)) {
                            Write-Host "Creating $FileType version folder: $VersionFolder" -ForegroundColor Cyan
                            New-Item -Path $TargetDownloadPath -ItemType Directory -Force -WhatIf:$WhatIfPreference | Out-Null
                        }
                    }
                    catch {
                        # Fall back to original path if version parsing fails
                        Write-Warning "Could not parse version '$VersionRaw' from $FileType file '$FileName'. Using default folder."
                    }
                }
                # Handle STIG Viewer User Guide
                elseif ($FileName -match '^U_STIG_Viewer_(\d+)-x_User_Guide.*\.pdf$') {
                    $MajorVersion = $Matches[1]
                    $FileType = "STIG Viewer"
                    $STIGViewerPath = $PSItem.OutFile

                    # Check if there are matching major version files in current download batch
                    $CurrentVersionFiles = $Downloads | Where-Object {
                        $_.OutFile -eq $STIGViewerPath -and
                        ($_.Uri -match "STIGViewer.*$MajorVersion-\d+-\d+" -or $_.Uri -match "STIGViewer_$MajorVersion-\d+-\d+")
                    }

                    if ($CurrentVersionFiles.Count -gt 0) {
                        # Extract version from one of the matching version files in this batch
                        $SampleVersionFile = ($CurrentVersionFiles[0].Uri -split '/')[-1]
                        if ($SampleVersionFile -match "$MajorVersion-(\d+-\d+)") {
                            $VersionFolder = "$MajorVersion.$($Matches[1] -replace '-', '.')"
                            $TargetDownloadPath = Join-Path -Path $STIGViewerPath -ChildPath $VersionFolder
                            Write-Host "Placing $FileType user guide in version folder: $VersionFolder" -ForegroundColor Cyan
                        }
                        else {
                            # Fallback to base folder if version can't be determined
                            $TargetDownloadPath = $STIGViewerPath
                            Write-Verbose "Could not determine $MajorVersion.x version for user guide, using base folder"
                        }
                    }
                    else {
                        # No matching version files found, use base folder
                        $TargetDownloadPath = $STIGViewerPath
                        Write-Verbose "No $MajorVersion.x version files found, placing user guide in base folder"
                    }

                    # Ensure the target directory exists
                    if (!(Test-Path $TargetDownloadPath)) {
                        New-Item -Path $TargetDownloadPath -ItemType Directory -Force -WhatIf:$WhatIfPreference | Out-Null
                    }
                }

                if (Test-Path "$TargetDownloadPath\$FileName") {
                    Write-Verbose "Skipping Existing File: $FileName"
                    $Skipped++
                }
                else {
                    Write-Host "Downloading File: $FileName" -ForegroundColor Green
                    $retryCount = 0
                    $maxRetries = 3
                    $downloaded = $false
                    do {
                        try {
                            Invoke-WebRequest -Uri $PSItem.Uri -TimeoutSec 15 -OutFile $(Join-Path -Path $TargetDownloadPath -ChildPath $FileName)
                            $downloaded = $true
                            $Success++
                            break
                        }
                        catch {
                            $retryCount++
                            if ($retryCount -ge $maxRetries) {
                                $Failure++
                                Write-Warning "Failed to download $Filename after $maxRetries attempts."
                                break
                            }
                            else {
                                Write-Verbose "Retry $retryCount of $maxRetries for $FileName"
                                Start-Sleep -Seconds 3
                            }
                        }
                    } while ($retryCount -lt $maxRetries)

                    if (!$downloaded) {
                        Write-Host "Failed to download: $FileName" -ForegroundColor Red
                    }
                }
            }
        } -End {
            if ($TotalFiles -gt 1) {
                Write-Progress -Activity "Downloading DISA Files" -Completed
            }
        }

        # Calculate execution time
        $EndTime = Get-Date
        $ExecutionTime = $EndTime - $StartTime

        # Create download summary by category
        $DownloadSummary = @{}
        foreach ($Switch in $PSBoundParameters.Keys) {
            if ($DownloadSwitches -contains $Switch) {
                $FolderPath = $DestinationPaths[$Switch]
                if ($FolderPath) {
                    $CategoryFiles = $Downloads | Where-Object { ($_.OutFile -split '\\')[-1] -eq $FolderPath.Split('\')[-1] }
                    if ($CategoryFiles) {
                        $DownloadSummary[$Switch] = $CategoryFiles.Count
                    }
                }
            }
        }

        # Display Summary
        Write-Host "`n$("="*60)" -ForegroundColor Cyan
        Write-Host "DOWNLOAD SUMMARY" -ForegroundColor Cyan
        Write-Host "$("="*60)" -ForegroundColor Cyan

        Write-Host "Execution Time: " -NoNewline
        Write-Host "$($ExecutionTime.Minutes)m $($ExecutionTime.Seconds)s" -ForegroundColor Cyan

        Write-Host "Destination: " -NoNewline
        Write-Host "$Destination" -ForegroundColor Yellow

        Write-Host "`nFile Statistics:" -ForegroundColor White
        Write-Host "  Total files attempted: " -NoNewline
        Write-Host $TotalFiles -ForegroundColor Green
        Write-Host "  Successfully downloaded: " -NoNewline
        Write-Host $Success -ForegroundColor Green
        Write-Host "  Skipped (already exist): " -NoNewline
        Write-Host $Skipped -ForegroundColor Yellow
        Write-Host "  Failed downloads: " -NoNewline
        Write-Host $Failure -ForegroundColor $(if ($Failure -gt 0) { "Red" } else { "Green" })

        if ($DownloadSummary.Count -gt 0) {
            Write-Host "`nFiles by Category:" -ForegroundColor White
            foreach ($Category in $DownloadSummary.GetEnumerator() | Sort-Object Name) {
                Write-Host "  $($Category.Key): " -NoNewline
                Write-Host $Category.Value -ForegroundColor Cyan
            }
        }

        # Chrome information
        if ($DownloadChrome) {
            Write-Host "`nChrome Setup:" -ForegroundColor White
            Write-Host "  Chrome Path: " -NoNewline
            Write-Host $ChromePath -ForegroundColor Yellow
            if ($CleanupChrome) {
                Write-Host "  Cleanup: " -NoNewline
                Write-Host "Scheduled for completion" -ForegroundColor Yellow
            }
            else {
                Write-Host "  Cleanup: " -NoNewline
                Write-Host "Chrome files retained" -ForegroundColor Yellow
            }
        }

        Write-Host "`n$("="*60)" -ForegroundColor Cyan

        if ($Failure -gt 0) {
            Write-Warning "Some files failed to download. Check the output above for details."
        }
        elseif ($Success -gt 0) {
            Write-Host "All downloads completed successfully!" -ForegroundColor Green
        }

        Write-Host "Downloads Complete. Files are located in: $Destination" -ForegroundColor Green
    }

    end {
        # Cleanup Chrome files if requested (and Chrome was downloaded)
        if ($DownloadChrome -and $CleanupChrome) {
            if (Test-Path $ChromePath) {
                Write-Host "Cleaning up Chrome files from: $ChromePath"
                try {
                    Remove-Item -Path $ChromePath -Recurse -Force -WhatIf:$WhatIfPreference
                    if (!$WhatIfPreference) {
                        Write-Host "Chrome cleanup completed successfully"
                    }
                }
                catch {
                    Write-Warning "Failed to cleanup Chrome files: $_"
                    Write-Warning "You may need to manually remove: $ChromePath"
                }
            }
            else {
                Write-Verbose "Chrome path not found for cleanup: $ChromePath"
            }
        }
    }
}
# UNCLASSIFIED