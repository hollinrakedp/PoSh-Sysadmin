function Enable-LocalUserPasswordExpiration {
    <#
    .SYNOPSIS
    Sets the password expiration policy for local users who currently have password expiration disabled.

    .DESCRIPTION
    This function identifies local users on a Windows system who are enabled and whose passwords are set to not expire and updates their password expiration policy to enforce expiration.

    .NOTES
    Name        : Enable-LocalUserPasswordExpiration
    Author      : Darren Hollinrake
    Version     : 1.0
    DateCreated : 2021-08-02
    DateUpdated :

    #>
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
    param ()

    $Users = Get-LocalUser | Where-Object { ($_.Enabled -eq $true) -and ($null -eq $_.PasswordExpires) }

    foreach ($User in $Users) {
        if ($PSCmdlet.ShouldProcess("$User")) {
            $User | Set-LocalUser -PasswordNeverExpires:$false
        }
    }
}