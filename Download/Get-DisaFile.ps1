function Get-DisaFiles {
    <#
    .SYNOPSIS
    Downloads DISA-related cybersecurity files from public sources such as DISA's website and NIWC's SCAP repository.
    
    .NOTES
    Name         - Get-DisaFiles
    Version      - 1.0
    Author       - Darren Hollinrake
    Date Created - 2024-09-27
    Date Updated - 2024-09-30

    .DESCRIPTION
    The Get-DisaFiles function downloads various cybersecurity resources from public URLs, including STIGs, Benchmarks,
    Enhanced Benchmarks, SCC files, and STIG Viewer. Users can specify which file types to download via switches and provide a
    destination folder for saving the downloaded files. The function creates the required directories for each file type if they
    do not already exist, and it avoids re-downloading files that are already present.
    The below folder structure is created (if all items are downloaded).
        $Destination
        ├───Benchmark
        ├───Enhanced Benchmark
        ├───GPO
        ├───SCC
        ├───STIG
        └───STIG Viewer
    
    .PARAMETER Destination
    Specifies the root folder where the files will be saved. This parameter is mandatory and should be a valid directory path.
    
    .PARAMETER Benchmark
    Download Benchmark files for use with SCC
    
    .PARAMETER EnhancedBenchmark
    Download Enhanced Benchmark-related files from the NIWC SCAP repository.
    
    .PARAMETER GPO
    Download the STIG GPO package.
    
    .PARAMETER SCC
    Download SCC installation files.
    
    .PARAMETER STIG
    Download STIG and SRG files.
    
    .PARAMETER StigViewer
    Download the STIG Viewer tool.
    
    .EXAMPLE
    Get-DisaFiles -Destination "C:\DisaFiles" -STIG -Benchmark
    Downloads STIG and Benchmark files to the "C:\DisaFiles" folder, creating the necessary subdirectories.
    
    .EXAMPLE
    Get-DisaFiles -Destination "C:\DisaFiles" -STIG -WhatIf
    Simulates downloading STIG files to "C:\DisaFiles", but doesn't actually download the files. Useful for testing.
    
    .LINK
    https://public.cyber.mil/stigs/downloads
    https://www.niwcatlantic.navy.mil/Technology/SCAP/SCAP-Content-Repository
    
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('Path')]
        [string]$Destination,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Benchmark,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$EnhancedBenchmark,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$GPO,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$SCC,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$STIG,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$StigViewer
    )

    begin {
        Write-Output "Retrieving list of files"
        try {
            $Data = (Invoke-WebRequest -Uri "https://public.cyber.mil/stigs/downloads" -TimeoutSec 15).Links.href
        }
        catch {
            Write-Error -Message "Unable to retrieve file list: $_" -ErrorAction Stop
        }

        try {
            $EnhancedData = (Invoke-WebRequest -Uri "https://www.niwcatlantic.navy.mil/Technology/SCAP/SCAP-Content-Repository"  -TimeoutSec 15).Links.href
        }
        catch {
            Write-Error -Message "Unable to retrieve enhanced file list: $_" -ErrorAction Stop
        }
    }

    process {

        $DestinationPaths = @{
            Benchmark         = Join-Path -Path $Destination -ChildPath "Benchmark"
            EnhancedBenchmark = Join-Path -Path $Destination -ChildPath "Enhanced Benchmark"
            GPO               = Join-Path -Path $Destination -ChildPath "GPO"
            SCC               = Join-Path -Path $Destination -ChildPath "SCC"
            STIG              = Join-Path -Path $Destination -ChildPath "STIG"
            StigViewer        = Join-Path -Path $Destination -ChildPath "STIG Viewer"
        }

        # Default to download all content if no download parameter is selected
        $DownloadSwitches = @('Benchmark', 'EnhancedBenchmark', 'GPO', 'SCC', 'STIG', 'StigViewer')
        if (-not ($PSBoundParameters.Keys | Where-Object { $downloadSwitches -contains $_ })) {
            Write-Output "No specific download switches provided. Defaulting to download all types."
            foreach ($Switch in $DownloadSwitches) {
                $PSBoundParameters[$switch] = $true
            }
        }

        # Create any required sub-directories
        $PSBoundParameters.Keys | Where-Object { $downloadSwitches -contains $_ } | ForEach-Object {
            $Path = $DestinationPaths[$_]
            if (!(Test-Path $Path)) {
                Write-Output "Creating directory: $Path"
                New-Item -Path $Path -ItemType Directory -Force -WhatIf:$WhatIfPreference | Out-Null
            }
        }

        $Downloads = @()

        foreach ($Switch in $PSBoundParameters.Keys) {
            $Links = @()
            switch ($Switch) {
                'Benchmark' {
                    $Links = $Data | Where-Object { $_ -match 'Benchmark' }
                }
                'EnhancedBenchmark' {
                    $Links = $EnhancedData | Where-Object { $_ -match 'Benchmark' } | ForEach-Object { "https://www.niwcatlantic.navy.mil/" + $_ }
                }
                'GPO' {
                    $Links = $Data | Where-Object { $_ -match 'STIG_GPO' }
                }
                'SCC' {
                    $Links = $Data | Where-Object { $_ -match 'SCC' }
                }
                'STIG' {
                    $Links = $Data | Where-Object { $_ -match 'STIG.zip|SRG.zip' -and $_ -notmatch 'Benchmark|mailto' }
                }
                'StigViewer' {
                    $Links = $Data | Where-Object { $_ -match 'STIGViewer' }
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

        $Downloads | ForEach-Object {
            $FileName = ($_.Uri -split '/')[-1]
            if ($PSCmdlet.ShouldProcess("$FileName", "Download File")) {
                if (Test-Path "$($PSItem.OutFile)\$FileName") {
                    "Skipping Existing File: $FileName"
                }
                else {
                    Write-Output "Downloading File: $FileName"
                    $retryCount = 0
                    $maxRetries = 3
                    do {
                        try {
                            Invoke-WebRequest -Uri $PSItem.Uri -TimeoutSec 15 -OutFile $PSItem.OutFile
                            break
                        }
                        catch {
                            $retryCount++
                            if ($retryCount -ge $maxRetries) {
                                $Failure++
                                Write-Warning "Failed to download $($PSItem.Uri) after $maxRetries attempts."
                                break
                            }
                            else {
                                Start-Sleep -Seconds 5
                            }
                        }
                    } while ($retryCount -lt $maxRetries)
                }
            }

        }
        Write-Output "Downloads Complete. Files are located in: $Destination"
        if ($Failure -ne 0) {
            Write-Warning "There were $Failure files that failed to download. Review the logs for additional details."
        }
    }

    end {}
}
# UNCLASSIFIED