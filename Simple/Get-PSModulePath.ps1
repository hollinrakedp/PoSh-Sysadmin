function Get-PSModulePath {
    <#
    .SYNOPSIS
    Gets the PowerShell module paths from the PSModulePath environment variable.

    .DESCRIPTION
    This function retrieves and displays the PowerShell module search paths by splitting the PSModulePath environment variable. Each path is displayed on a separate line for easy reading.

    .EXAMPLE
    Get-PSModulePath

    #>
    param()

    $env:PSModulePath -split ';'
}