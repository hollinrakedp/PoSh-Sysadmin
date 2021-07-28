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

    .PARAMETER DisplayLogonInfo

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
        [switch]$DisplayLogonInfo,
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
                    Audit {
                        Write-Verbose "Applying GPO: AppLockerAudit"
                        & LGPO.exe /p '.\GPO\Custom\Custom - Computer - App - Config - AppLocker - Audit.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                    Enforce {
                        Write-Verbose "Applying GPO: AppLockerEnforce"
                        & LGPO.exe /p '.\GPO\Custom\Custom - Computer - App - Config - AppLocker - Enforce.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                }
            }
        }
        Defender {
            if ($PSCmdlet.ShouldProcess("Defender: $Defender", "Apply GPO")) {
                Write-Verbose "Applying GPO: Defender"
                & LGPO.exe /p '.\GPO\DoD\DoD Windows Defender Antivirus STIG Computer v2r2.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
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
        DisplayLogonInfo {
            if ($PSCmdlet.ShouldProcess("DisplayLogonInfo: $DisplayLogonInfo", "Apply GPO")) {
                Write-Verbose "Applying GPO: Disable Logon Info"
                & LGPO.exe /p '.\GPO\Custom\Custom - Computer - Display Previous Logon Info.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
            }
        }
        IE11 {
            if ($PSCmdlet.ShouldProcess("IE11: $IE11", "Apply GPO")) {
                Write-Verbose "Applying GPO: IE11"
                & LGPO.exe /p '.\GPO\DoD\DoD Internet Explorer 11 STIG Computer v1r19.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                & LGPO.exe /p '.\GPO\DoD\DoD Internet Explorer 11 STIG User v1r19.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
            }
        }
        Firewall {
            if ($PSCmdlet.ShouldProcess("Firewall: $Firewall", "Apply GPO")) {
                Write-Verbose "Applying GPO: Firewall"
                & LGPO.exe /p '.\GPO\DoD\DoD Windows Firewall STIG v1r7.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
            }
        }
        NetBanner {
            if ($PSCmdlet.ShouldProcess("NetBanner: $Netbanner", "Apply GPO")) {
                Write-Verbose "NetBanner was specified"
                switch ($Netbanner) {
                    FOUO {
                        Write-Verbose "Applying GPO: NetbannerFOUO"
                        & LGPO.exe /p '.\GPO\Custom\Custom - NetBanner - UnclassifiedFOUO.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                    Secret {
                        Write-Verbose "Applying GPO: NetbannerSecret"
                        & LGPO.exe /p '.\GPO\Custom\Custom - NetBanner - Secret.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                    SecretNoForn {
                        Write-Verbose "Applying GPO: NetbannerSecretNoForn"
                        & LGPO.exe /p '.\GPO\Custom\Custom - NetBanner - SecretNoForn.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                    Test {
                        Write-Verbose "Applying GPO: NetbannerTest"
                        & LGPO.exe /p '.\GPO\Custom\Custom - NetBanner - Test.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                    TopSecret {
                        Write-Verbose "Applying GPO: NetbannerTopSecret"
                        & LGPO.exe /p '.\GPO\Custom\Custom - NetBanner - TopSecret.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                    Unclass {
                        Write-Verbose "Applying GPO: NetbannerUnclass"
                        & LGPO.exe /p '.\GPO\Custom\Custom - NetBanner - Unclassified.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                }
            }
        }
        NoPreviousUser {
            if ($PSCmdlet.ShouldProcess("NoPreviousUser: $NoPreviousUser", "Apply GPO")) {
                Write-Verbose "Applying GPO: NoPreviousUser"
                & LGPO.exe /p '.\GPO\Custom\Custom - Computer - Do Not Display Last User Name.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
            }
        }
        Office {
            if ($PSCmdlet.ShouldProcess("Office: $Office", "Apply GPO")) {
                Write-Verbose "Office was specified"
                switch ($Office) {
                    #Test for version of Office installer?
                    '2013' {
                        Write-Verbose "Applying GPO: Office2013"
                    }
                    '2016' {
                        Write-Verbose "Applying GPO: Office2016"
                        & LGPO.exe /p '.\GPO\DoD\DoD Office 2016 Computer STIG COMBINED.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                        & LGPO.exe /p '.\GPO\DoD\DoD Office 2016 User STIG COMBINED.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                    '2019' {
                        Write-Verbose "Applying GPO: Office 2019"
                    }
                }
            }
        }
        RequireCtrlAltDel {
            if ($PSCmdlet.ShouldProcess("RequireCtrlAltDel: $RequireCtrlAltDel", "Apply GPO")) {
                Write-Verbose "Applying GPO: RequireCtrlAltDel"
                & LGPO.exe /p '.\GPO\Custom\Custom - Computer - Require Ctrl Alt Del.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
            } 
        }
        OS {
            if ($PSCmdlet.ShouldProcess("OS: $OS", "Apply GPO")) {
                Write-Verbose "OS was specified"
                switch ($OS) {
                    # Test for version?: Get-CIMInstance -ClassName Win32_OperatingSystem | select caption
                    Win10 {
                        Write-Verbose "Applying GPO: Win10"
                        & LGPO.exe /p '.\GPO\DoD\DoD Windows 10 STIG Computer v2r2.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                        & LGPO.exe /p '.\GPO\DoD\DoD Windows 10 STIG User v2r2.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                    Server2016 {
                        Write-Verbose "Applying GPO: MS Server 2016"
                        & LGPO.exe /p '.\GPO\DoD\DoD Windows Server 2016 Member Server STIG Computer v2r2.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                        & LGPO.exe /p '.\GPO\DoD\DoD Windows Server 2016 Member Server STIG User v2r2.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                    Server2019 {
                        Write-Verbose "Applying GPO: Server 2019"
                        & LGPO.exe /p '.\GPO\DoD\DoD Windows Server 2019 Member Server STIG Computer v2r2.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                        & LGPO.exe /p '.\GPO\DoD\DoD Windows Server 2019 Member Server STIG User v2r2.PolicyRules' /v > { $env:COMPUTERNAME }_lgpo.log 2> { $env:COMPUTERNAME }_lgpo.err
                    }
                }
            }
        }

    }
}