#Requires -modules ActiveDirectory, DHLog
function Get-ADInactiveAccount {
    <#
    .SYNOPSIS
    Displays inactive AD accounts.

    .DESCRIPTION
    The function is used to identify all enabled Active Directory accounts that are currently inactive for the specified number of days. It has the ability to disable the accounts found to be inactive.

    .NOTES   
    Name       : Get-InactiveAccount
    Author     : Darren Hollinrake
    Version    : 1.1
    DateCreated: 2019-01-03
    DateUpdated: 2021-10-14

    .PARAMETER Days
    The number of days before an accoutn is considered inactive

    .PARAMETER Disable
    Disables the inactive accounts and updates the description field to indicate the date they were disabled.

    .PARAMETER NeverLoggedIn
    Gets only inactive accounts that have never logged in.

    .EXAMPLE
    Get-ADInactiveAccount
    Displays a list of user accounts that are inactive in the Active Directory domain. Because the days parameter was not set, the default of 45 days is used

    .EXAMPLE
    Get-ADInactiveAccount -Disable
    Disables all inactive user accounts found in the Active Directory domain. These accounts can be seen by running 'Get-InactiveAccount' to ensure needed accounts are not disabled accidentally.

    .EXAMPLE
    Get-ADInactiveAccount -NeverLoggedIn -Days 30
    Displays a list of user accounts that were created at least 30 days ago and have never logged in.

    .EXAMPLE
    Get-ADInactiveAccount -NeverLoggedIn -Days 30 -Disable
    Disables all user accounts that have never logged in and were created at least 30 days ago.

    #>
    [CmdletBinding(DefaultParameterSetName = "Inactive")]
    param(
        [Parameter(ParameterSetName = 'Inactive')]
        [Parameter(ParameterSetName = 'NeverLoggedIn')]
        [int]$Days = "45",
        [Parameter(ParameterSetName = 'Inactive')]
        [Parameter(ParameterSetName = 'NeverLoggedIn')]
        [switch]$Disable,
        [Parameter(ParameterSetName = 'NeverLoggedIn')]
        [switch]$NeverLoggedIn
    )
    
    Write-LogEntry -StartLog
    Write-Verbose "The Parameter set in use: $($PSCmdlet.ParameterSetName)"
    Write-LogEntry "Getting AD accounts that are inactive for $Days days or greater."

    If ($($PSCmdlet.ParameterSetName) -eq "Inactive") {
        $Accounts = Search-ADAccount -AccountInactive -UsersOnly -DateTime ((Get-Date).AddDays(-$Days)) | Where-Object { ($_.Enabled -eq $true) -and ($_.PasswordNeverExpires -eq $false) }
    }

    If ($($PSCmdlet.ParameterSetName) -eq "NeverLoggedIn") {
        $Accounts = Search-ADAccount -AccountInactive -UsersOnly -DateTime ((Get-Date).AddDays(-$Days)) | Where-Object { ($_.Enabled -eq $true) -and ($_.PasswordNeverExpires -eq $false) -and ($null -eq $_.LastLogonDate) } | Get-ADUser -Properties whencreated | Where-Object { $_.whencreated -lt ((Get-Date).AddDays(-$days)) }
    }

    If ($Disable) {
        Write-LogEntry "Disabling accounts inactive for at least $Days days."
        $Accounts | Disable-ADAccount -PassThru | ForEach-Object -Process {
            Write-LogEntry "Disabled $($_.Name) - ($($_.SamAccountName))"
            $CurrentDescription = (Get-ADUser $_.SamAccountName -Properties Description | Select-Object Description).Description
            $AddDescription = " - Disabled $(Get-Date -Format yyyyMMdd) - Inactive >$days days"
            $NewDescription = "$CurrentDescription" + "$AddDescription"
            $_ | Set-ADUser -Description "$NewDescription"
        }
    }
    Else {
        $Accounts | Select-Object Name, SamAccountName, DistinguishedName
    }
    Write-LogEntry -StopLog
}