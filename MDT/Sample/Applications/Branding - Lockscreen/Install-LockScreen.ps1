<#
Import as a standard application in MDT.
Quiet install command:
    PowerShell.exe -ExecutionPolicy Bypass -NoProfile -Command .\Install-LockScreen.ps1

The following images are needed:
    Name		    Resolution
    ---------	    -------------
    img100.jpg      1920x1200*

    *The resolution can be higher than this

Due to the need to copy to a protected system location, files need to be transferred to a temporary location locally and then to their final destiantion.
#>

# Ensure we have elevated rights
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    exit 1
}

$LocalTemp = "$env:SystemDrive\temp\LockScreen"

# Create the App Directory
If(!(Test-Path "$LocalTemp")) {
    New-Item -ItemType Directory -Path "$LocalTemp" -Force
}

# Copy the folder to the local system
Copy-Item "$PSScriptRoot\*" "$LocalTemp" -Force -Recurse

# Apply the image as the lock screen
# Take ownership of the existing lock screen files
takeown /f $env:SystemRoot\Web\Screen\*

# Assign full permissions to the existing lock screen files to Administrators
& icacls $env:SystemRoot\Web\Screen\* /Grant Administrators:`(F`)

# Delete the existing files
Remove-Item $env:SystemRoot\Web\Screen\*

# Copy our new lock screen files to the proper location
Copy-Item "$LocalTemp\img100.jpg" "$env:SystemRoot\Web\Screen"

# Add the registry key so the lock screen is set to the image we copied
REG ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization /v LockScreenImage /t REG_SZ /d "$env:SystemRoot\Web\Screen\img100.jpg"

# Give ownership back to Trusted Installer
& icacls $env:SystemRoot\Web\Screen\* /setowner "NT SERVICE\TrustedInstaller"

# Cleanup temp files
Remove-Item -Path "$LocalTemp" -Recurse