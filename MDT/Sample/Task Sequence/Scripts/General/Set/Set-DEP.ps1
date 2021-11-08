<#
.SYNOPSIS
Set Data Execution Prevention (DEP) to OptOut.

.DESCRIPTION
The script sets Data Execution Prevention (DEP) to OptOut if not already set.

Windows 10 STIG
----------------
Finding ID: V-68845
Version:    WN10-00-000145
Rule ID:    SV-83439r1_rule

Data Execution Prevention (DEP) must be configured to at least OptOut.

Description:
Attackers are constantly looking for vulnerabilities in systems and applications. Data Execution Prevention (DEP) prevents harmful code from running in protected memory locations reserved for Windows and other programs.


.NOTES   
Name       : Set-DEP.ps1
Author     : Darren Hollinrake
Version    : 1.0
DateCreated: 2018-02-20
DateUpdated: 2020-05-21

MDT Use:
Add to the task sequence during the 'State Restore' portion.

Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Set DEP
PowerShell script: %SCRIPTROOT%\General\Set\Set-DEP.ps1

#>

# Get current DEP configuration
$DEPValue = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object DataExecutionPrevention_SupportPolicy
# Set DEP
If ($DEPValue.DataExecutionPrevention_SupportPolicy -eq 3) {
    Write-Output "DEP is already set to OptOut. No futher action is required."
    } Else {
    Write-Output "Setting DEP to OptOut."
    BCDEDIT /set "{current}" nx OptOut
    }