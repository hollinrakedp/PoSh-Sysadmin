#Requires -modules ActiveDirectory, Write-LogEntry
function Get-ADLockedOutAccount {
    <#
    .SYNOPSIS
    Displays locked out AD accounts.

    .DESCRIPTION
    The function is used to identify all enabled Active Directory accounts that are currently locked out. It has the ability to also unlock the accounts.

    .NOTES   
    Name       : Get-LockedOutAccount
    Author     : Darren Hollinrake
    Version    : 1.0
    DateCreated: 2019-01-02
    DateUpdated: 

    .PARAMETER Unlock
    Displays an interactive list of Active Directory accounts that are locked. Accounts that are selected are then unlocked.

    .PARAMETER UnlockAll
    Unlocks all enabled Active Directory accounts.

    .EXAMPLE
    Get-ADLockedOutAccount
    Displays a non-interactive list of accounts that are locked out in the Active Directory domain.

    .EXAMPLE
    Get-ADLockedOutAccount -Unlock
    Displays an interactive list of accounts that are locked out in the Active Directory domain. Select one or more accounts to unlock from the 

    #>

    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(ParameterSetName = 'Default')]
        [switch]$Unlock,
        [Parameter(ParameterSetName = 'UnlockAll')]
        [switch]$UnlockAll
    )
    # Display any accounts that are locked out, if the 'Unlock' parameter was specified, display a selectable list of accounts to unlock
    $Accounts = Search-ADAccount -LockedOut -UsersOnly | Where-Object {$_.Enabled -eq $true}
    If (!($Unlock)){
        $Accounts | Select-Object Name, SamAccountName, LastLogonDate, LockedOut
    } else {
        $Accounts = $Accounts | Select-Object Name, SamAccountName, LastLogonDate, LockedOut | Out-Gridview -Title "Select the account(s) to unlock." -PassThru
    }
    # Unlock all accounts listed as locked out.
    If ($Unlock -or $UnlockAll){
        If ($Accounts.count -eq 0) {
            Write-LogEntry "Unlocking AD Accounts was specified but no account(s) is(are) available/selected for unlocking."
        } else {
            $Accounts | ForEach-Object -Begin{
                Write-LogEntry "Unlocking AD accounts."
            } -Process {
                Write-LogEntry "Unlocking: $($_.SamAccountName)"
                Unlock-ADAccount -Identity $_.SamAccountName
            } -End {
                Write-LogEntry "Finished unlocking accounts"
            }
        }
    }
}

function Get-ADInactiveAccount {
    <#
    .SYNOPSIS
    Displays inactive AD accounts.

    .DESCRIPTION
    The function is used to identify all enabled Active Directory accounts that are currently inactive for the specified number of days. It has the ability to disable the accounts found to be inactive.

    .NOTES   
    Name       : Get-InactiveAccount
    Author     : Darren Hollinrake
    Version    : 1.0
    DateCreated: 2019-01-03
    DateUpdated: 

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
    
    # Write the name of the function being called
    Write-LogEntry $MyInvocation.MyCommand.Name
    Write-LogEntry "The Parameter set in use: $($PSCmdlet.ParameterSetName)"
    Write-LogEntry "Getting accounts that are inactive for $Days days."

    If ($($PSCmdlet.ParameterSetName) -eq "Inactive"){
        $Accounts = Search-ADAccount -AccountInactive -UsersOnly -DateTime ((Get-Date).AddDays(-$Days)) | Where-Object {($_.Enabled -eq $true) -and ($_.PasswordNeverExpires -eq $false)}
    }

    If ($($PSCmdlet.ParameterSetName) -eq "NeverLoggedIn"){
        $Accounts = Search-ADAccount -AccountInactive -UsersOnly -DateTime ((Get-Date).AddDays(-$Days)) | Where-Object {($_.Enabled -eq $true) -and ($_.PasswordNeverExpires -eq $false) -and ($null -eq $_.LastLogonDate)} | Get-ADUser -Properties whencreated | Where-Object {$_.whencreated -lt ((Get-Date).AddDays(-$days))}
    }

    If ($Disable) {
        Write-LogEntry "Disabling accounts inactive for at least $Days days."
        $Accounts | Disable-ADAccount -PassThru | ForEach-Object -Process {
            Write-LogEntry "Disabled $($_.Name) ($($_.SamAccountName))"
            $CurrentDescription = (Get-ADUser $_.SamAccountName -Properties Description | Select-Object Description).Description
            $AddDescription = " - Disabled $(Get-Date -Format yyyyMMdd) - Inactive >$days days"
            $UpdatedDescription = "$CurrentDescription" + "$AddDescription"
            $_ | Set-ADUser -Description "$UpdatedDescription"
        }
    } Else {
        $Accounts | Select-Object Name, SamAccountName, DistinguishedName
    }
}

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