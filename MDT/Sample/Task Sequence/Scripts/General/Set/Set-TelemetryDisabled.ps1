<#
Set Telemetry options to disable collection

Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Remove Built-In Apps
PowerShell script: %SCRIPTROOT%\General\Set\Set-TelemetryDisabled.ps1
#>
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /f /t REG_DWORD /v AllowTelemetry /d 0