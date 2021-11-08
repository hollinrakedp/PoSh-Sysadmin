<#
Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Remove Built-In Apps
PowerShell script: %SCRIPTROOT%\General\Tattoo\Set-CustomTattoo.ps1
#>

# Apply a registry key for the date of capture
reg add "HKLM\SOFTWARE\Microsoft\Deployment 4" /v "Capture Date" /t REG_SZ /d (Get-Date -Format yyyy-MM-dd)
# Convert existing timestamp property to usable format
#$BuildDate = "Build Date:`t" + [datetime]::parseexact(((Get-ItemProperty -Path "Registry::HKLM\SOFTWARE\Microsoft\Deployment 4")."Capture Timestamp").Substring(0,8), "yyyyMMdd",$null)
#
# Create a build file
If(!(Test-Path "$env:SystemDrive\buildinfo.txt")) {
    New-Item -ItemType "file" -Path "$env:SystemDrive\buildinfo.txt"
    }

$TaskSequenceName = "Release:`t" + (Get-ItemProperty -Path "Registry::HKLM\SOFTWARE\Microsoft\Deployment 4")."Capture Task Sequence Name"
$TaskSequenceVersion = "Version:`t" + (Get-ItemProperty -Path "Registry::HKLM\SOFTWARE\Microsoft\Deployment 4")."Capture Task Sequence Version"
$BuildDate = "Build Date:`t" + (Get-ItemProperty -Path "Registry::HKLM\SOFTWARE\Microsoft\Deployment 4")."Capture Date"

$TaskSequenceName | Out-File -FilePath "$env:SystemDrive\buildinfo.txt" -Append
$TaskSequenceVersion | Out-File -FilePath "$env:SystemDrive\buildinfo.txt" -Append
$BuildDate | Out-File -FilePath "$env:SystemDrive\buildinfo.txt" -Append

