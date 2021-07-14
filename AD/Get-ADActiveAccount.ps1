#Requires -modules ActiveDirectory, Write-LogEntry
function Get-ADActiveAccount {
    <#
    .SYNOPSIS
    Displays the AD accounts of enabled users.

    .DESCRIPTION
    The function is used to identify all enabled Active Directory accounts that are currently enabled. It has the ability to show enabled accounts that have a password set to never expire.

    .NOTES   
    Name       : Get-ActiveAccount
    Author     : Darren Hollinrake
    Version    : 1.0
    DateCreated: 2019-01-03
    DateUpdated: 

    .PARAMETER CountOnly
    The number of days before an account is considered inactive

    .PARAMETER PwdNeverExpires
    Disables the inactive accounts and updates the description field to indicate the date they were disabled.

    .EXAMPLE
    Get-ActiveAccount
    Shows a list of accounts that are enabled and whose passwords are set to expire.

    .EXAMPLE
    Get-ActiveAccount -CountOnly -PwdNeverExpires
    Displays a total count of the number of accounts with passwords set to never expire.

    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$CountOnly,
        [Parameter()]
        [switch]$PwdNeverExpires
    )

    # Convert switch parameter to boolean
    [bool]$PwdNeverExpires = $PwdNeverExpires

    $ActiveUsers = Get-ADUser -Filter { (Enabled -eq $true) -and (PasswordNeverExpires -eq $PwdNeverExpires)}
    Write-LogEntry "Total Enabled Accounts: $($ActiveUsers.count)"
    If (!($CountOnly)){
        $ActiveUsers | Select-Object Name, SamAccountName | Sort-Object Name
    }
}