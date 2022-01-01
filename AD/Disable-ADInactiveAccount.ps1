#-Requires -modules ActiveDirectory, DHLog
function Disable-ADInactiveAccount {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$Days = "60",
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$AddDescription,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Description = " - Disabled $(Get-Date -Format yyyyMMdd) - Inactive >$days days",
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$IgnoreAccount,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$DisabledAccountOU = "OU=Disabled users, $((Get-ADDomain -Current LocalComputer).DistinguishedName)",
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$ToCSV,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CSVPath
    )
    begin {
        if ($PSCmdlet.ShouldProcess()) {
            Write-LogEntry -StartLog 
        }
    }
    process {
        if ($PSCmdlet.ShouldProcess()) {
            Write-LogEntry "Disabling AD accounts that are inactive for $Days days or greater."
        }
        $Accounts = Search-ADAccount -AccountInactive -UsersOnly -DateTime ((Get-Date).AddDays(-$Days)) | Where-Object { ($_.Enabled -eq $true) -and ($_.PasswordNeverExpires -eq $false) }
        Write-LogEntry "Found $($Accounts.count) account(s) to disable"
        if ($Accounts.count -lt 1) {
            Write-LogEntry "Nothing to do; Exiting"
            Write-LogEntry -StopLog
            return
        }
        if ($PSCmdlet.ShouldProcess("$Account", "Disable-ADAccount")) {
            foreach ($Account in $Accounts) {
                if ($Account -in $IgnoreAccount) {
                    Write-LogEntry "Ignoring: $($_.Name) - ($($_.SamAccountName))"
                }
                else {
                    Write-LogEntry "Disabling: $($_.Name) - ($($_.SamAccountName))"
                    switch ($PSBoundParameters.Keys) {
                        AddDescription { 
                            $CurrentDescription = (Get-ADUser $_.SamAccountName -Properties Description | Select-Object Description).Description
                            $NewDescription = "$CurrentDescription" + "$Description"
                            $Account | Set-ADUser -Description "$NewDescription"
                        }
                        ToCSV {
                            $Account | Select-Object Name, SamAccountName, DistinguishedName | Export-Csv -Path $CSVPath -NoTypeInformation
                        }
                    }
                    $Account | Disable-ADAccount
                    $Account | Move-ADObject -TargetPath $DisabledAccountOU
                }
            }
            
        }
    }
    end { }
}