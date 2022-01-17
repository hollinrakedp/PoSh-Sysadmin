function Get-STIGCheckerConfig {
    <#
    .SYNOPSIS
    

    .DESCRIPTION
    This function gets the configuration file for the STIG environment.

    .NOTES
    Name         - 
    Version      - 0.1
    Author       - Darren Hollinrake
    Date Created - 
    Date Updated - 
    
    .PARAMETER FilePath
    

    #>
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory)]
        [Alias('Path')]
        [string]$ConfigPath
    )
    if ((Test-Path $ConfigPath) -and ($ConfigPath -match '^*\.json')) {
        $STIGEnvironmentConfigObj = Get-Content "$ConfigPath" | ConvertFrom-Json
    }
    else {
        Write-Warning "The specified path is not valid. Please provide a valid config file path to import."
        return
    }
    $STIGEnvironmentConfigObj
}