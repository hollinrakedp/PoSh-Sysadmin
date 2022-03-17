function Install-MSI {
    <#
    .SYNOPSIS
    Install MSI files.

    .DESCRIPTION

    .NOTES   
    Name       : Install-MSI
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