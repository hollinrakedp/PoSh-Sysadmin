<#
MDT Use:
Add to the task sequence during the 'State Restore' portion.

Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Remove Task View Icon
PowerShell script: %SCRIPTROOT%\General\Removal\Remove-TaskViewIcon.ps1

#>

# Remove the Task View icon from the taskbar
reg load "HKU\TEMP" "$env:SystemDrive\Users\Default\NTUSER.DAT"
reg add "HKU\TEMP\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d 0 /f
reg unload "HKU\TEMP"