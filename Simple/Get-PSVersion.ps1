function Get-PSVersion {
    <#
    .SYNOPSIS
    Gets the PowerShell version information.

    .DESCRIPTION
    This function retrieves PowerShell version information. By default, it returns just the PowerShell version number. With the -Full parameter, it returns all details from the $PSVersionTable automatic variable.

    .PARAMETER Full
    When specified, returns the complete PowerShell version table with all available information including edition, OS, platform, GitCommitId, and other details.

    .EXAMPLE
    Get-PSVersion
    7.4.0

    .EXAMPLE
    Get-PSVersion -Full
    Returns the complete PowerShell version table with all available information.

    #>
    param(
        [Parameter()]
        [switch]$Full
    )

    if ($Full) {
        $PSVersionTable
    }
    else {
        $PSVersionTable.PSVersion
    }
}