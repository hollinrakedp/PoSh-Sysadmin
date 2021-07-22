<#
.SYNOPSIS
Disables PowerShell V2.

.DESCRIPTION
The script removes the Windows feature for PowerShell V2.

Windows 10 STIG
----------------
Finding ID: V-70637
Version:    WN10-00-000155
Rule ID:    SV-85259r1_rule

The Windows PowerShell 2.0 feature must be disabled on the system.

Description:
Windows PowerShell 5.0 added advanced logging features which can provide additional detail when malware has been run on a system. Disabling the Windows PowerShell 2.0 mitigates against a downgrade attack that evades the Windows PowerShell 5.0 script block logging feature.


.NOTES   
Name       : Remove-PowerShellV2.ps1
Author     : Darren Hollinrake
Version    : 1.0
DateCreated: 2018-02-20
DateUpdated: 2018-07-21
#>

###############
#   Logging   #
###############
$LogPath = "C:\Custom\Logs\"
If (!(Test-Path "$LogPath")) {New-Item -ItemType Directory -Force -Path "$LogPath"}
$scriptname = [io.path]::GetFileNameWithoutExtension("$($MyInvocation.MyCommand.Name)")
$TransactionLog = $LogPath + $(Get-Date -Format yyyyMMdd) + "_" + $scriptname + ".log"
Start-Transcript -LiteralPath $TransactionLog
###############

If ((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root).State -eq "Disabled"){
    Write-Host "Feature is already removed. Nothing to do..."} Else {
    Write-Host "Removing Feature: $((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root).DisplayName)"
    Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -Verbose
    }

Stop-Transcript