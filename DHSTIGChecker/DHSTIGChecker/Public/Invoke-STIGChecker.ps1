function Invoke-STIGCheck {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Windows10', 'Server2016', 'Server2019')]
        [string]$STIG,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$ID,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Path')]
        [string]$ConfigPath
    )
    
    begin {
        try {
            $EnvConfig = Get-STIGEnvironmentConfig -ConfigPath "$ConfigPath"
        }
        catch {
            Write-Warning "Failed to get the Environment configuration file."
            return
        }
        
        try {
            $ComputerInfo = Get-STIGComputerInfo
        }
        catch {
            Write-Warning "Failed to get the Computer information."
            return
        }

        $AuditPolicy = Get-AdvancedAuditPolicy | Select-Object 'Subcategory', 'Inclusion Setting'

        $HasBluetooth = Test-HasBluetooth

        $SIDLocalGroup = @{
            Administrators     = "S-1-5-32-544"
            Users              = "S-1-5-32-545"
            Guests             = "S-1-5-32-546"
            RemoteDesktopUsers = "S-1-5-32-555"
            Service            = "S-1-5-6"
            LocalService       = "S-1-5-19"
            NetworkService     = "S-1-5-20"
            LocalAccount       = "S-1-5-113"
        }

        $IsDomainJoined = $ComputerInfo.CsPartOfDomain

        if ($IsDomainJoined) {
            Write-Verbose "System is joined to a Domain."
            Write-Verbose "Gathering needed Domain SIDs."
            try {
                $SIDDomainGroup = @{
                    DomainAdmins     = $(Get-ADSIGroupSID -sAMAccountName 'Domain Admins')
                    EnterpriseAdmins = $(Get-ADSIGroupSID -sAMAccountName 'Enterprise Admins')
                }
            }
            catch {
                Write-Warning "Unable to gather Domain SIDs. Results may not be accurate."
            }
        }
    }
    
    process {
        
    }
    
    end {
        $SIDLocalGroup
        $EnvConfig
        $ComputerInfo
    }
}