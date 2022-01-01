function Test-RegistryKeyValue {
    <#
    .SYNOPSIS
    Tests if a registry value exists.

    .DESCRIPTION
    This function checks to see if the specified Registry Key Value exists. It will return True if the Key Value exists and False if it does not.

    .EXAMPLE
    Test-RegistryKeyValue -Path 'HKLM:\SYSTEM\State\DateTime' -Name 'NTP Enabled'
    True

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (!(Test-Path -Path $Path -PathType Container) ) {
        return $false
    }

    $Properties = Get-ItemProperty -Path $Path 
    if (! $Properties ) {
        return $false
    }

    $Member = Get-Member -InputObject $Properties -Name $Name
    if ( $Member ) {
        return $true
    }
    else {
        return $false
    }

}