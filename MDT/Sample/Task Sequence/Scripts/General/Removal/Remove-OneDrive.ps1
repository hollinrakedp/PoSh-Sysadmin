<#
.SYNOPSIS
Removes OneDrive from the system and prevents it from installing on a per-user basis.

.DESCRIPTION
This script will remove OneDrive from the system and prevent the per-user installation. First, it will attempt to uninstall OneDrive from the current system. It will then delete the installer and remove the OneDriveSetup script from running for each user. Next, it will remove the Start Menu and Explorer links and scheduled task from the system.

.NOTES
Name            : Remove-OneDrive.ps1
Author          : Darren Hollinrake
Version         : 0.9
Date Created    : 2019-02-24
Date Updated    : 2020-05-21

MDT Use:
Add to the task sequence during the 'State Restore' portion.

Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Remove OneDrive
PowerShell script: %SCRIPTROOT%\nss-mdt-scripts\Removal\Remove-OneDrive.ps1

#>

# Remove the OneDrive installer and the registry key that tells it to run once.

# Stop the OneDrive process so we can uninstall it
Get-Process -Name "OneDrive" | Stop-Process
Start-Process -FilePath "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait

# Remove the installer from the system
takeown /F "$env:SystemDrive\Windows\SysWOW64\OneDriveSetup.exe" /A
icacls "$env:SystemDrive\Windows\SysWOW64\OneDriveSetup.exe" /Grant Administrators:`(F`)
Remove-Item "$env:SystemDrive\Windows\SysWOW64\OneDriveSetup.exe" -Force
Remove-Item "$env:ProgramData\Microsoft OneDrive" -Recurse -Force

# Stop RunOnce from launching the installer
reg load "HKLM\WIM" "$env:SystemDrive\Users\Default\NTUSER.DAT"
reg delete "HKLM\WIM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f
reg unload "HKLM\WIM"

#region Cleanup

# Remove Explorer link
reg add "HKCR\CLSID{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f
# Remove Start Menu link
Remove-Item -Force "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
# Remove Scheduled Task
Get-ScheduledTask -TaskName "OneDrive*" | Unregister-ScheduledTask -Confirm:$false

#endregion
