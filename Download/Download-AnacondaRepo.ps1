<#
.SYNOPSIS
Downloads Anaconda repository files.

.NOTES
Name: Download-AnacondaRepo.ps1
Version      - 1.1
Author       - Darren Hollinrake
Date Created - 2024-10-05
Date Updated - 

.DESCRIPTION
This script downloads files from specified Anaconda repository URLs into a designated directory. 
It processes the files in parallel, limiting the number of simultaneous downloads with the `MaxJobs` parameter. 
It creates a directory structure based on the repository channel and architecture for organization.

Find available repos:
    https://repo.anaconda.com/pkgs/
Create custom repo (untested):
    https://stackoverflow.com/questions/35359147/how-can-i-host-my-own-private-conda-repository

.PARAMETER AnacondaRepo
A list of Anaconda repository URLs to download from. Defaults to several common repository URLs.

.PARAMETER DownloadDir
The directory where the downloaded files will be stored. A subfolder is created for each repository channel and architecture. 
Defaults to 'C:\Downloads\Anaconda\pkgs'.

.PARAMETER MaxJobs
Specifies the maximum number of parallel downloads to run simultaneously. The default is 8, but this can be adjusted based on system and network performance.

.EXAMPLE
.\Download-Anaconda.ps1

Downloads Anaconda repository files using the default URLs and saves them in the default download directory.

.EXAMPLE
.\Download-Anaconda.ps1 -AnacondaRepo @(
    "https://repo.anaconda.com/pkgs/main/linux-64",
    "https://repo.anaconda.com/pkgs/free/linux-64"
) -DownloadDir "D:\AnacondaPackages" -MaxJobs 4

Downloads files from specified repositories to 'D:\AnacondaPackages' with up to 4 parallel downloads.

.EXAMPLE
.\Download-Anaconda.ps1 -MaxJobs 10

Runs the script with default repositories, saving files to the default download directory but allows 10 parallel jobs.

.LINK
https://repo.anaconda.com/pkgs/
https://stackoverflow.com/questions/35359147/how-can-i-host-my-own-private-conda-repository

#>

param (
    [string[]]$AnacondaRepo = @(
        "https://repo.anaconda.com/pkgs/main/noarch",
        "https://repo.anaconda.com/pkgs/free/noarch",
        "https://repo.anaconda.com/pkgs/r/noarch",
        "https://repo.anaconda.com/pkgs/main/win-64",
        "https://repo.anaconda.com/pkgs/free/win-64",
        "https://repo.anaconda.com/pkgs/r/win-64",
        "https://repo.anaconda.com/pkgs/msys2/win-64"
    ),
    [string]$DownloadDir = "C:\Downloads\Anaconda\pkgs",
    [int]$MaxJobs = 8
)

$Stopwatch = [system.diagnostics.stopwatch]::StartNew()
$RepoTotalCount = $AnacondaRepo.Count
$RepoCount = 0

foreach ($Repo in $AnacondaRepo) {
    $RepoCount++
    $RepoChildDirArch = ($Repo.Split('/'))[-1]
    $RepoChildDirChannel = ($Repo.Split('/'))[-2]
    Write-Progress -Id 0 -Activity "Processing Repository $RepoCount of $RepoTotalCount" -Status "Repository - Channel: $RepoChildDirChannel - Arch: $RepoChildDirArch"
    $RepoDir = Join-Path -Path $DownloadDir -ChildPath $RepoChildDirChannel
    $RepoDir = Join-Path -Path $RepoDir -ChildPath $RepoChildDirArch
    if (! (Test-Path $RepoDir)) {
        New-Item -Path $RepoDir -ItemType Directory -Force
    }
    $RepoFile = (Invoke-WebRequest -Uri "$Repo").Links.href | Where-Object { $_ -like "*.tar.bz2" }
    $RepoTotalFileCount = $RepoFile.Count
    $RepoFileCount = 0
    foreach ($File in $RepoFile) {
        $RepoFileCount++
        Write-Progress -Id 1 -ParentId 0 -Activity "Processing File $RepoFileCount of $RepoTotalFileCount" -Status "File - $File"
        if (!(Test-Path "$RepoDir\$File")) {
            $WebRequestParams = @{
                Uri     = "$Repo/$File"
                OutFile = "$RepoDir\$File"
            }
            [int]$RunningCnt = (Get-Job -State Running).Count
            if ($RunningCnt -lt $MaxJobs) {
                Start-Job -ScriptBlock { Invoke-WebRequest @Using:WebRequestParams } | Out-Null
            }
            else {
                Get-Job -State Running | Wait-Job -Any
                Start-Job -ScriptBlock { Invoke-WebRequest @Using:WebRequestParams } | Out-Null
            }
            Get-Job -State Completed | Remove-Job
        }
    }
    Write-Progress -Id 1 -ParentId 0 -Activity "Downloading Files" -Complete
}

Write-Progress -Id 0 -Activity "Downloading Repo(s)" -Complete
$Stopwatch.Stop()
$Stopwatch.Elapsed | Format-Table
