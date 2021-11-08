<#
.SYNOPSIS
Set the registry keys necessary to mitigate speculative execution.

.DESCRIPTION
The script creates the registry keys and values needed to enable mitigations for speculative execution (Spectre/Meltdown).

These setting are for Intel processors with hyperthreading enabled. If hyperthreading is disabled, change the value of'FeatureSettingsOverride' to '8264'

.NOTES   
Name       : Set-SpeculativeExecution.ps1
Author     : Darren Hollinrake
Version    : 1.0
DateCreated: 2020-03-20
DateUpdated: 2020-05-21

MDT Use:
Add to the task sequence during the 'State Restore' portion.

Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Set Speculative Execution Mitigation
PowerShell script: %SCRIPTROOT%\General\Set\Set-SpeculativeExecution.ps1

#>

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d 72 /f
