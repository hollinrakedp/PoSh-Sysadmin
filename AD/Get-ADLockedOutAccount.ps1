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



