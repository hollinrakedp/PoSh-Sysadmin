<#
Keep the crap out of the start menu.

Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Remove Built-In Apps
PowerShell script: %SCRIPTROOT%\General\Set\Set-ConsumerFeatureOff.ps1
#>
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f