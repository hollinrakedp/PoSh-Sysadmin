function Invoke-LocalGPO {
    <#
    .SYNOPSIS
    Applies GPOs against the local system.

    .DESCRIPTION


    .NOTES

    .PARAMETER AdminCDRW

    .PARAMETER AdminRemDriveRW

    .PARAMETER NonAdminCDRead

    .PARAMETER AppLocker

    .PARAMETER Defender
    DISA GPO

    .PARAMETER DisableCortana

    .PARAMETER DisableRemovableStorage

    .PARAMETER DisableLogonInfo

    .PARAMETER IE11
    DISA GPO

    .PARAMETER Firewall
    DISA GPO

    .PARAMETER NetBanner

    .PARAMETER NoPreviousUser

    .PARAMETER Office
    DISA GPO

    .PARAMETER RequireCtrlAltDel

    .PARAMETER OS
    DISA GPO

    .EXAMPLE
    Invoke-LocalGPO

    #>
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$AdminCDRW,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$AdminRemDriveRW,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$NonAdminCDRead,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Audit', 'Enforce')]
        [string]$AppLocker,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Defender,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DisableCortana,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DisableRemovableStorage,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DisableLogonInfo,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$IE11,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Firewall,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('FOUO', 'Secret', 'SecretNoForn', 'TopSecret', 'Unclass', 'Test')]
        [Alias('NB')]
        [string]$NetBanner,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$NoPreviousUser,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('2013', '2016', '2019')]
        [string]$Office,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$RequireCtrlAltDel,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Win10', 'Server2016', 'Server2019')]
        [string]$OS
    )

    switch ($PSBoundParameters.Keys) {
        AdminCDRW {
            if ($PSCmdlet.ShouldProcess("AdminCDRW: $AdminCDRW", "Apply GPO")) {
                Write-Verbose "Applying GPO: AdminCDRW"
            } 
        }
        AdminRemDriveRW {
            if ($PSCmdlet.ShouldProcess("AdminRemDriveRW: $AdminRemDriveRW", "Apply GPO")) {
                Write-Verbose "Applying GPO: AdminRemDriveRW"
            }
        }
        NonAdminCDRead {
            if ($PSCmdlet.ShouldProcess("NonAdminCDRead: $NonAdminCDRead", "Apply GPO")) {
                Write-Verbose "Applying GPO: NonAdminCDRead"
            }
        }
        Applocker {
            if ($PSCmdlet.ShouldProcess("AppLocker: $AppLocker", "Apply GPO")) {
                Write-Verbose "Applocker was specified"
                switch ($AppLocker) {
                    Audit { Write-Verbose "Applying GPO: AppLockerAudit" }
                    Enforce { Write-Verbose "Applying GPO: AppLockerEnforce" }
                }
            }
        }
        Defender {
            if ($PSCmdlet.ShouldProcess("Defender: $Defender", "Apply GPO")) {
                Write-Verbose "Applying GPO: Defender"
            }
        }
        DisableCortana {
            if ($PSCmdlet.ShouldProcess("DisableCortana: $DisableCortana", "Apply GPO")) {
                Write-Verbose "Applying GPO: Disable Cortana"
            }
        }
        DisableCEIP {
            if ($PSCmdlet.ShouldProcess("DisableCEIP: $DisableCEIP", "Apply GPO")) {
                Write-Verbose "Applying GPO: Disable CEIP"
            }
        }
        DisableRemovableStorage {
            if ($PSCmdlet.ShouldProcess("DisableRemovableStorage: $DisableRemovableStorage", "Apply GPO")) {
                Write-Verbose "Applying GPO: DisableRemovableStorage"
            }
        }
        DisableLogonInfo {
            if ($PSCmdlet.ShouldProcess("DisableLogonInfo: $DisableLogonInfo", "Apply GPO")) {
                Write-Verbose "Applying GPO: Disable Logon Info"
            }
        }
        IE11 {
            if ($PSCmdlet.ShouldProcess("IE11: $IE11", "Apply GPO")) {
                Write-Verbose "Applying GPO: IE11"
            }
        }
        Firewall {
            if ($PSCmdlet.ShouldProcess("Firewall: $Firewall", "Apply GPO")) {
                Write-Verbose "Applying GPO: Firewall"
            }
        }
        NetBanner {
            if ($PSCmdlet.ShouldProcess("NetBanner: $Netbanner", "Apply GPO")) {
                Write-Verbose "NetBanner was specified"
                switch ($Netbanner) {
                    FOUO { Write-Verbose "Applying GPO: NetbannerFOUO" }
                    Secret { Write-Verbose "Applying GPO: NetbannerSecret" }
                    SecretNoForn { Write-Verbose "Applying GPO: NetbannerSecretNoForn" }
                    Test { Write-Verbose "Applying GPO: NetbannerTest" }
                    TopSecret { Write-Verbose "Applying GPO: NetbannerTopSecret" }
                    Unclass { Write-Verbose "Applying GPO: NetbannerUnclass" }
                }
            }
        }
        NoPreviousUser {
            if ($PSCmdlet.ShouldProcess("NoPreviousUser: $NoPreviousUser", "Apply GPO")) {
                Write-Verbose "Applying GPO: NoPreviousUser"
            }
        }
        Office {
            if ($PSCmdlet.ShouldProcess("Office: $Office", "Apply GPO")) {
                Write-Verbose "Office was specified"
                switch ($Office) {
                    #Test for version of Office installer?
                    '2013' { Write-Verbose "Applying GPO: Office2013" }
                    '2016' { Write-Verbose "Applying GPO: Office2016" }
                    '2019' { Write-Verbose "Applying GPO: Office 2019" }
                }
            }
        }
        RequireCtrlAltDel {
            if ($PSCmdlet.ShouldProcess("RequireCtrlAltDel: $RequireCtrlAltDel", "Apply GPO")) {
                Write-Verbose "Applying GPO: RequireCtrlAltDel"
            } 
        }
        OS {
            if ($PSCmdlet.ShouldProcess("OS: $OS", "Apply GPO")) {
                Write-Verbose "OS was specified"
                switch ($OS) {
                    # Test for version?: Get-CIMInstance -ClassName Win32_OperatingSystem | select caption
                    Win10 { Write-Verbose "Applying GPO: Win10" }
                    Server2016 { Write-Verbose "Applying GPO: Server 2016" }
                    Server2019 { Write-Verbose "Applying GPO: Server 2019" }
                }
            }
        }

    }
}