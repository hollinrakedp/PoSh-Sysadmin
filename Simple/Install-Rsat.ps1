function Install-RsatFeature {
    <#
    .SYNOPSIS
    Installs RSAT features from a specified source directory.

    .DESCRIPTION
    This script installs Remote Server Administration Tools (RSAT) features on a Windows machine
    using a specified source directory for the installation files.

    .PARAMETER Source
    The path to the directory containing the RSAT installation files.

    .EXAMPLE
    Install-RsatFeature -Source "E:\LanguagesAndOptionalFeatures"

    .NOTES
    Name         - Install-RSAT
    Version      - 1.0
    Author       - Darren Hollinrake
    Date Created - 2025-11-04
    Date Updated -

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Path to the Languages and Optional Features source directory")]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$Source
    )

    $RSATFeatures = Get-WindowsCapability -Online -Name RSAT* -LimitAccess -Source $Source

    foreach ($RSATFeature in $RSATFeatures) {
        Add-WindowsCapability -Online -Name $RSATFeature.Name -LimitAccess -Source $Source
    }
}