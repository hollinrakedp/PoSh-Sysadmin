<#
MDT Use:
Add to the task sequence during the 'State Restore' portion.

Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Remove Cortana Search Box
PowerShell script: %SCRIPTROOT%\General\Removal\Remove-CortanaSearchBox.ps1

#>

# Hide Cortana search box from the taskbar
reg load "HKU\TEMP" "$env:SystemDrive\Users\Default\NTUSER.DAT"
reg add "HKU\TEMP\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f
reg unload "HKU\TEMP"