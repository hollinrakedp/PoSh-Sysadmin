function Invoke-STIGChecker {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({
                if ($_ -in (& $TabCompleteAvailableSTIGs)) {
                    $true
                }
                else {
                    throw "The supplied value `'$_`' is invalid. Valid values: $($STIGPath.Name -join ', ')"
                }
            })]
        [string]$Name,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Path')]
        [string]$ConfigPath
    )
    
    begin {
        try {
            $EnvConfig = Get-STIGCheckerConfig -ConfigPath "$ConfigPath"
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

        SecEdit.exe /Export  /cfg currentsecpolicy.txt | Out-Null
        $CurrentSecPolicy = @{}
        Get-Content .\currentsecpolicy.txt | Where-Object { ($_ -match '=') -and ($_ -notmatch 'MACHINE') } | ForEach-Object { $Script:CurrentSecPolicy += ConvertFrom-StringData $_ }
        Remove-Item .\currentsecpolicy.txt
        
        $AuditPolicy = Get-AdvancedAuditPolicy | Select-Object 'Subcategory', 'Inclusion Setting'
        $HasBluetooth = Test-HasBluetooth
        $DeviceGuard = Get-DeviceGuard
        $IsClassified = $EnvConfig.IsClassified
        $IsVDI = $EnvConfig.IsVDI
        $VDINonPersist = $EnvConfig.VDINonPersist

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
        $STIGs = Get-ChildItem "$STIGRootPath/$Name"

        $VulnResults = @()

        #Initialize Counters
        [int]$STIGCounter = 0
        [int]$STIGCounterNA = 0
        [int]$STIGCounterO = 0
        [int]$STIGCounterNF = 0
        [int]$STIGCounterNR = 0
    }
    
    process {
        Write-Verbose "Found $($STIGS.Count) Checks."
        foreach ($STIG in $STIGs) {
            $STIGCounter++
            #Write-Progress -Activity "Running STIG Checks" -Status "Check: VulnID $($STIG.BaseName)" -PercentComplete ($STIGCounter / $STIGS.Count * 100)
            Write-Verbose "Check: $STIGCounter"
            Write-Verbose "Vulnerability ID: $($STIG.BaseName)"
            Write-Verbose "$($STIG.FullName)"
            [string]$result = . $STIG.FullName
            switch ($result) {
                True {
                    $STIGCounterNF++
                    $result = 'Not a Finding'
                }
                False {
                    $STIGCounterO++
                    $result = 'Open'
                }
                'Not Applicable' { $STIGCounterNA++ }
                'Not Reviewed' { $STIGCounterNR++ }
            }
            $VulnResults += [PSCustomObject]@{
                VulnID = $($STIG.BaseName)
                Result = $result
            }
        }

        Write-Verbose "Completed:       $STIGCounter"
        Write-Verbose "Open:            $STIGCounterO ($([math]::Round($($STIGCounterO/$STIGCounter*100)))%)"
        Write-Verbose "Not a Finding:   $STIGCounterNF ($([math]::Round($($STIGCounterNF/$STIGCounter*100)))%)"
        Write-Verbose "Not Reviewed:    $STIGCounterNR ($([math]::Round($($STIGCounterNR/$STIGCounter*100)))%)"
        Write-Verbose "Not Applicable:  $STIGCounterNA ($([math]::Round($($STIGCounterNA/$STIGCounter*100)))%)"
        
        #$VulnResults #| Group-Object -Property Result
        
        $ResultsCount = @{
            'Total Checks'   = $STIGCounter
            'Not Applicable' = $STIGCounterNA
            Open             = $STIGCounterO
            'Not a Finding'  = $STIGCounterNF
            'Not Reviewed'   = $STIGCounterNR
        }

        $ResultsStatus = @{
            'Not Applicable' = ($VulnResults | Where-Object {$_.Result -eq 'Not Applicable'}).VulnID
            Open             = ($VulnResults | Where-Object {$_.Result -eq 'Open'}).VulnID
            'Not a Finding'  = ($VulnResults | Where-Object {$_.Result -eq 'Not a Finding'}).VulnID
            'Not Reviewed'   = ($VulnResults | Where-Object {$_.Result -eq 'Not Reviewed'}).VulnID
        }

        $STIGCheckerResults = @{
            ComputerName        = $env:COMPUTERNAME
            STIG                = $Name
            Classified          = $IsClassified
            'Domain Joined'     = $IsDomainJoined
            'VDI System'        = $IsVDI
            'Persistent VDI'    = $VDINonPersist
            'Results Count'     = $ResultsCount
            'Results By Status' = $ResultsStatus
            Data                = $VulnResults
        }

        $STIGCheckerResults
    }
    
    end {
        
    }
}