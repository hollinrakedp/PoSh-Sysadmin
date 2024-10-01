# UNCLASSIFIED
function Get-NessusInstaller {
    <#
    .SYNOPSIS
    Downloads the latest Nessus installer for selected platforms (RHEL7, RHEL8, Windows 32-bit, or Windows 64-bit).

    .NOTES
    Name         - Get-NessusInstaller
    Version      - 1.1
    Author       - Darren Hollinrake
    Date Created - 2024-09-29
    Date Updated - 2024-09-30

    .DESCRIPTION
        This cmdlet retrieves the latest Nessus version information from Tenable's download page
        and downloads the installer for the specified platforms. It supports downloading for 
        RHEL7x64, RHEL8x64, Win32, and Win64 platforms.

    .PARAMETER Path
        Specifies the directory where the installers will be downloaded.

    .PARAMETER Platform
        Specifies the platform for which the Nessus installer should be downloaded.
        Accepted values: 'RHEL7x64', 'RHEL8x64', 'Win32', 'Win64'.
        Default value: 'Win64'.

    .EXAMPLE
        Get-NessusInstaller -Path "C:\Installers" -Platform RHEL7x64, Win64

        Downloads the Nessus installer for both RHEL7x64 and Windows 64-bit platforms 
        and saves them to the "C:\Installers" directory.

    .LINK
        https://www.tenable.com/downloads/api/v2/pages/nessus

    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string]$Path,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('RHEL7x64', 'RHEL8x64', 'Win32', 'Win64')]
        [string[]]$Platform = 'Win64'
    )
    
    begin {}
    
    process {
        try {
            $Data = Invoke-RestMethod -Uri "https://www.tenable.com/downloads/api/v2/pages/nessus"
        }
        catch {
            Write-Error -Message "Failed to retrieve Nessus version information: $_"
            return
        }

        $ReleaseName = ($Data.releases.latest | Get-Member -MemberType NoteProperty).Name
        $ReleaseVersion = ($ReleaseName -split '-')[-1].Trim()
        $InstallerReleasePath = Join-Path -Path $Path -ChildPath $ReleaseVersion
        
        $Installers = @{
            RHEL7x64 = $Data.releases.latest.$ReleaseName | Where-Object { $_.OS -eq 'Linux' -and $_.file -like "*el7.x86_64.rpm" }
            RHEL8x64 = $Data.releases.latest.$ReleaseName | Where-Object { $_.OS -eq 'Linux' -and $_.file -like "*el8.x86_64.rpm" }
            Win32    = $Data.releases.latest.$ReleaseName | Where-Object { $_.OS -eq 'Windows' -and $_.file -like "*Win32.msi" }
            Win64    = $Data.releases.latest.$ReleaseName | Where-Object { $_.OS -eq 'Windows' -and $_.file -like "*x64.msi" }
        }

        Write-Host "The following platform(s) will be downloaded: $($Platform -join ', ')"

        $Downloads = $Platform | ForEach-Object { $Installers[$_] }

        if (! (Test-Path -Path $InstallerReleasePath)) {
            New-Item -Path $InstallerReleasePath -ItemType Directory -Force -WhatIf:$WhatIfPreference | Out-Null
        }

        foreach ($Download in $Downloads) {
            if (Test-Path "$InstallerReleasePath\$($Download.file)") {
                Write-Host "The file `"$($Download.file)`" has already been downloaded. Skipping..."
            }
            else {
                if ($PSCmdlet.ShouldProcess("$($Download.file_url)", "Download Installer")) {
                    try {
                        Write-Host "Downloading: $($Download.file)"
                        Invoke-WebRequest -Uri $Download.file_url -OutFile "$InstallerReleasePath\$($Download.file)"
                        Write-Host "Download Complete"
                    }
                    catch {
                        Write-Error -Message "Failed to download file `"$($Download.file)`": $_"
                    }
                }
            }
        }
    }
    
    end {}
}