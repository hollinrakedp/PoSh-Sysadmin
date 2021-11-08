<#
Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Remove Built-In Apps
PowerShell script: %SCRIPTROOT%\General\Removal\Remove-PeopleIcon.ps1
#>
reg load "HKU\TEMP" "$env:SystemDrive\Users\Default\NTUSER.DAT"
reg add "HKU\TEMP\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v HidePeopleBar /t REG_DWORD /d 1 /f
reg unload "HKU\TEMP"