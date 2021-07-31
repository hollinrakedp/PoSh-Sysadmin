function Set-LocalUserPasswordExpires {
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
    param (
    )
    $Users = Get-LocalUser | Where-Object { ($_.Enabled -eq $true) -and ($null -eq $_.PasswordExpires) }
    
    foreach ($User in $Users) {
        if ($PSCmdlet.ShouldProcess("$User")) {
            $User | Set-LocalUser -PasswordNeverExpires:$false
        }
    }
}