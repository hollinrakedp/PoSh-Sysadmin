<#
MDT Use:
Add to the task sequence during the 'State Restore' portion.

Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Remove News and Interests icon
PowerShell script: %SCRIPTROOT%\General\Removal\Remove-TaskViewIcon.ps1

#>

# Remove the News and Interests icon from the taskbar
reg load "HKU\TEMP" "$env:SystemDrive\Users\Default\NTUSER.DAT"
reg add "HKU\TEMP\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d 2 /f
reg unload "HKU\TEMP"