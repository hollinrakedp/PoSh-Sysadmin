<#
Import as a standard application in MDT.
Quiet install command:
    PowerShell.exe -ExecutionPolicy Bypass -NoProfile -Command .\Install-DefaultBackground.ps1

The following images are needed:
    Name		        Resolution
    ---------	        -------------
    img0_786x1024.jpg   768x1024
    img0_768x1366.jpg   768x1366
    img0_1024x768.jpg   1024x768
    img0_1080x1920.jpg  1080x1920
    img0_1200x1920.jpg  1200x1920
    img0_1366x768.jpg   1366x768
    img0_1440x2560.jpg  1440x2560
    img0_1600x2560.jpg  1600x2560
    img0_1920x1080.jpg  1920x1080
    img0_1920x1200.jpg  1920x1200
    img0_2160x3840.jpg  2160x3840
    img0_2560x1440.jpg  2560x1440
    img0_2560x1600.jpg  2560x1600
    img0_3840x2160.jpg  3840x2160
    img0.jpg            1920x1200

Due to the need to copy to a protected system location, files need to be transferred to a temporary location locally and then to their final destiantion.
#>

# Ensure we have elevated rights
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    exit 1
}

$LocalTemp = "$env:SystemDrive\temp\DefaultBackground"

# Create the App Directory
If(!(Test-Path "$LocalTemp")) {
    New-Item -ItemType Directory -Path "$LocalTemp" -Force
}

# Copy the folder to the local system
Copy-Item "$PSScriptRoot\*" "$LocalTemp" -Force -Recurse

# Take ownership of the existing wallpaper files
takeown /f $env:SystemRoot\Web\4K\Wallpaper\Windows\*
takeown /f $env:SystemRoot\Web\Wallpaper\Windows\img0.jpg

# Assign full permissions to the existing wallpaper files to Administrators
& icacls $env:SystemRoot\Web\Wallpaper\Windows\img0.jpg /Grant Administrators:`(F`)
& icacls $env:SystemRoot\Web\4K\Wallpaper\Windows\* /Grant Administrators:`(F`)

# Delete the existing files
Remove-Item $env:SystemRoot\Web\4K\Wallpaper\Windows\*
Remove-Item $env:SystemRoot\Web\Wallpaper\Windows\img0.jpg

# Copy our new wallpaper files to the proper location
Copy-Item "$LocalTemp\img0.jpg" "C:\Windows\Web\Wallpaper\Windows\img0.jpg"
Copy-Item "$LocalTemp\img0_*.jpg" "C:\Windows\Web\4K\Wallpaper\Windows"

# Give ownership back to Trusted Installer
& icacls $env:SystemRoot\Web\Wallpaper\Windows\img0.jpg /setowner "NT SERVICE\TrustedInstaller"
& icacls $env:SystemRoot\Web\4K\Wallpaper\Windows\* /setowner "NT SERVICE\TrustedInstaller"

# Cleanup temp files
Remove-Item -Path "$LocalTemp" -Recurse