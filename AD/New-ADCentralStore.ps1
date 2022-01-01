function New-ADCentralStore {
    <#
    .SYNOPSIS
    Creates the Central Store for Group Policy

    .DESCRIPTION
    Run from a DC. Copies the local C:\Windows\PolicyDefinitions folder to C:\Windows\SYSVOL\domain\Policies

    .NOTES
    Name       : New-ADCentralStore
    Author     : Darren Hollinrake
    Version    : 0.1
    DateCreated: 2021-12-29
    DateUpdated: 

    #>

    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SourcePath = "C:\Windows",
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$DestinationPath = "C:\Windows\SYSVOL\domain\Policies"
    )

    if (!(Test-Path "$DestinationPath\PolicyDefinitions")) {
        Write-Verbose "Central Store doesn't exist, creating it now."
        Copy-Item -Path "$SourcePath\PolicyDefinitions" -Destination "$DestinationPath" -Recurse -Verbose:$VerbosePreference
    }
}