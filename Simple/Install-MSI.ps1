function Install-Msi {
    <#
    .SYNOPSIS
    Install MSI files from a specified directory.

    .DESCRIPTION
    This function recursively searches for MSI files in the specified path and installs them using msiexec.exe.
    It supports quiet installation, preventing automatic restarts, and custom logging options. The function
    processes all MSI files found and provides feedback on installation success or failure.

    .PARAMETER Path
    Specifies the directory path to search for MSI files. Defaults to current directory (".\").
    The function will recursively search subdirectories for MSI files.

    .PARAMETER Quiet
    When specified, performs a quiet installation without user interaction (/qn parameter).

    .PARAMETER NoRestart
    When specified, prevents automatic restart after installation (/norestart parameter).

    .PARAMETER LogPath
    Specifies the directory path where installation logs will be saved. Defaults to "C:\Temp\Logs".
    Log files will contain detailed installation information for troubleshooting.

    .EXAMPLE
    Install-Msi
    
    Installs all MSI files found in the current directory with default settings.

    .EXAMPLE
    Install-Msi -Path "C:\Software" -Quiet -NoRestart
    
    Performs a quiet installation of all MSI files in C:\Software without restarting the system.

    .EXAMPLE
    Install-Msi -Path ".\Updates" -LogPath "C:\Logs\Installations"
    
    Installs MSI files from the Updates subdirectory and saves logs to C:\Logs\Installations.

    .NOTES   
    Name       : Install-Msi
    Author     : Darren Hollinrake
    Version    : 0.1
    DateCreated: 2021-12-29
    DateUpdated: 

    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Path = ".\",
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Quiet,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$NoRestart,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LogPath = "C:\Temp\Logs"
    )

    begin {
        $Installers = Get-ChildItem "$Path\*" -Include *.msi -Recurse
    }
    
    process {
        foreach ($MSI in $Installers) {
            $MsiArgs = @(
                "/i"
                "`"$($MSI.FullName)`""
            )
            $MsiArgs += switch ($PSBoundParameters) {
                Quiet { "/qn" }
                NoRestart { "/norestart" }
                LogPath { "/l* `"$LogPath`""}
            }

            # Run msiexec to install the application
            $Install = Start-Process -FilePath msiexec -ArgumentList $MsiArgs -PassThru -Wait
            $Install.WaitForExit()
            If (($Install.ExitCode -eq 0) -or ($Install.ExitCode -eq 3010)) {
                Write-Output "Installed $MSI successfully."
            }
            else {
                Write-Warning "Installation of $MSI failed with code: $($Install.ExitCode)"
            }
        }
    }
    
    end {}
}