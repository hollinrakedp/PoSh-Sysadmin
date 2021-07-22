<#
.SYNOPSIS
This script will assist with quickly locking down the local system of a Windows 10 installation.

.NOTES
Name        : Execute-Custom_Lockdown.ps1
Author      : Darren Hollinrake
Version     : 2.1
DateCreated : 2018-03-05
DateUpdated : 2018-11-13

Version 2.X is a major overhaul of the script.

You are now able to run individual lockdown scripts by supplying the appropriate parameters. The application of the Local 
GPO's will run with the script defaults. If you need specific GPO's applied, you may call ".\GPO\Apply-LocalGPO.bat" with 
the appropriate parameters.

.DESCRIPTION
This script will assist with quickly locking down the local system of a Windows 10 installation. Specify parameters to lock 
down the system as required for your environment. The default should be sufficient in most cases. This script requires the 
supporting files be located in specific directories relative to where the script is saved.

.PARAMETER SetLGPO
Applies DISA STIG GPO's against the local system.

.PARAMETER SetEP
Applies the Exploit Protection policy.

.PARAMETER SetDEP
Sets the Data Execution Prevention policy to 'Opt-Out'.

.PARAMETER DisablePosh2
Disables PowerShell v2.

.PARAMETER DisableCortana
Disables Cortana.

.PARAMETER DisableSchTask
Disables Unnecessary Scheduled Tasks.

.PARAMETER DisableServices
Disables Unnecessary Services.

.PARAMETER SetSROAuditing
Sets auditing on Security Relevant Objects (SRO's).

.PARAMETER EnableEventLogs
Enables the Print Services and Task Scheduler Operational event logs.

.PARAMETER RunSCC
Runs a scan using the SCAP Compliance Checker.

.EXAMPLE
Execute-Custom_Lockdown.ps1
This will execute the script with the default settings.
The following switches are set by default:
    -SetLGPO -SetEP -SetDEP -DisablePosh2 -DisableSchTask -DisableServices -EnableEventLogs -SetSROAuditing
Local GPOs will be applied, Exploit Protection policy will be applied, DEP will be set to Opt-Out, PoShv2 will be disabled, 
scheduled tasks will be disabled, services will be disabled, event logs will be enabled, and auditing will be enabled on SRO's.

.EXAMPLE
Execute-Custom_Lockdown.ps1 -SetLGPO -SetEP -SetDEP -DisablePosh2 -DisableSchTask -DisableServices -EnableEventLogs -SetSROAuditing
This is identical to Example 1. Local GPOs will be applied, Exploit Protection policy will be applied, DEP will be set to 
Opt-Out, PoShv2 will be disabled, scheduled tasks will be disabled, services will be disabled, event logs will be enabled, and 
auditing will be enabled on SRO's.

#>

[CmdletBinding(DefaultParameterSetName = 'Default')]

Param (
  [Parameter(ParameterSetName='Custom', HelpMessage="Applies DISA STIG GPO's against the local system.")]
  [Alias("ApplyLGPO")]
  [Switch]$SetLGPO,
  [Parameter(ParameterSetName='Custom', HelpMessage="Applies the Exploit Protection policy.")]
  [Alias("ApplyEP")]
  [Switch]$SetEP,
  [Parameter(ParameterSetName='Custom', HelpMessage="Sets the Data Execution Prevention policy to 'Opt-Out'.")]
  [Alias("ApplyDEP")]
  [Switch]$SetDEP,
  [Parameter(ParameterSetName='Custom', HelpMessage="Disables PowerShell v2.")]
  [Switch]$DisablePosh2,
  [Parameter(ParameterSetName='Custom', HelpMessage="Disables Cortana.")]
  [Switch]$DisableCortana,
  [Parameter(ParameterSetName='Custom', HelpMessage="Disables Unnecessary Scheduled Tasks.")]
  [Switch]$DisableSchTask,
  [Parameter(ParameterSetName='Custom', HelpMessage="Disables Unnecessary Services.")]
  [Switch]$DisableServices,
  [Parameter(ParameterSetName='Custom', HelpMessage="Enables the Print Services and Task Scheduler Operational event logs.")]
  [Switch]$EnableEventLogs,
  [Parameter(ParameterSetName='Custom', HelpMessage="Configures SRO's for auditing.")]
  [Switch]$SetSROAuditing,
  [Parameter(ParameterSetName='Custom', HelpMessage="Runs a scan using the SCAP Compliance Checker.")]
  [Alias("ScanNow")]
  [Switch]$RunSCC
  )


#region Variables
#########################################
#                                       #
#            Set Variables              #
#                                       #
#########################################
# LGPO
$SetLGPOScript = Join-Path -Path $PSScriptRoot -ChildPath "GPO\Apply-LocalGPO.bat"
# Configuration item outside LGPO
$SetOfficeScript = Join-Path -Path $PSScriptRoot -ChildPath "Apply-STIG_DTOO425.ps1"
# DEP (WN10-00-000145)
$SetDEPScript = Join-Path -Path $PSScriptRoot -ChildPath "Set-DEP.ps1"
# PowerShell v2 (WN10-00-000155)
$DisablePosh2Script = Join-Path -Path $PSScriptRoot -ChildPath "Remove-PowerShellV2.ps1"
# Exploit Protection
$SetEPScript = Join-Path -Path $PSScriptRoot -ChildPath "ExploitProtection\Set-ExploitProtection.ps1"
# Scheduled Task
$DisableSchTaskScript = Join-Path -Path $PSScriptRoot -ChildPath "Set-SchTasksDisabled.ps1"
# Services
$DisableServicesScript = Join-Path -Path $PSScriptRoot -ChildPath "Set-ServicesDisabled.ps1"
# Enable Event Logs
$EnableEventLogsScript = Join-Path -Path $PSScriptRoot -ChildPath "Enable-EventLogs.ps1"
# SRO Auditing
$SetSROAuditingScript = Join-Path -Path $PSScriptRoot -ChildPath "Auditing\Set-SRO_Auditing.ps1"
# SCC
$RunSCCScript = Join-Path -Path $PSScriptRoot -ChildPath "Execute-SCC_Scan.cmd"
#endregion Variables

# Set appropriate switches if none are specified
If ($PSCmdlet.ParameterSetName -eq "Default") {
    Write-Output "No parameters were set, using the defaults."
    $SetLGPO = $true
    $SetEP = $true
    $SetDEP = $true
    $DisablePosh2 = $true
    $DisableSchTask = $true
    $DisableServices = $true
    $EnableEventLogs = $true
    $SetSROAuditing = $true
}


##################################################
#                                                #
#                   Execution                    #
#                                                #
##################################################
If ($DisableCortana) {
    Write-Output "Disabling Cortana"
    REG ADD "HKLM\SOFTWARE\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
    }

If ($SetDEP) {
    Write-Output "Applying the DEP Opt-Out setting"
    & $SetDEPScript
    }

If ($DisablePosh2) {
    Write-Output "Disabling PowerShell v2"
    & $DisablePosh2Script
    }

If ($SetEP) {
    Write-Output "Applying Exploit Protection Policy"
    & $SetEPScript
    }

If ($DisableSchTask) {
    Write-Output "Disabling Unnecessary Tasks"
    & $DisableSchTaskScript
    }

If ($DisableServices) {
    Write-Output "Disables Unnecessary Services."
    & $DisableServicesScript
    }

If ($SetSROAuditing) {
    Write-Output "Setting Auditing on SRO's"
    & $SetSROAuditingScript
    }

If ($EnableEventLogs) {
    Write-Output "Enabling Print Service and Task Scheduler Operational Event Logs"
    & $EnableEventLogsScript
    }

If ($SetLGPO) {
    # Copy Administrative Templates and their corresponding language files to the proper location
    Write-Output "Copying Administrative Templates to the local 'PolicyDefinitions' folder."
    Get-ChildItem -path "$env:SystemDrive\Custom\Lockdown\GPO\*" -Include "*.admx" -Recurse | ForEach-Object { Copy-Item -Path $_.FullName -Destination "$env:SystemRoot\PolicyDefinitions" }
    Get-ChildItem -path "$env:SystemDrive\Custom\Lockdown\GPO\*" -Include "*.adml" -Recurse | ForEach-Object { Copy-Item -Path $_.FullName -Destination "$env:SystemRoot\PolicyDefinitions\en-US" }
    # Apply the GPO Backups to the local machine using the LGPO tool.
    Write-Output "Applying Local GPOs"
    Start-Process $SetLGPOScript -Wait -NoNewWindow
    & "$SetOfficeScript"
    }

If ($RunSCC) {
    Write-Output "Beginning SCC Scan"
    Start-Process $RunSCCScript -Wait -NoNewWindow
    }