function Invoke-HardenSystem {
    <#
    .SYNOPSIS
    Quickly hardens the local Windows installion system.

    .DESCRIPTION
    This function allows for quickly hardening the local Windows system. Run the function without specifying any parameters to use the default hardening configuration which should be fine for most Windows 10 installations.

    .NOTES
    Name         - Invoke-HardenSystem
    Version      - 0.1
    Author       - Darren Hollinrake
    Date Created - 2021-07-24
    Date Updated - 

    .PARAMETER ApplyGPO

    .PARAMETER DEP

    .PARAMETER DisablePoShV2

    .PARAMETER DisableScheduledTask

    .PARAMETER DisableService

    .PARAMETER EnableLog

    .PARAMETER Mitigation

    .EXAMPLE


    #>
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [array]$ApplyGPO,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('AlwaysOff', 'AlwaysOn', 'OptIn', 'OptOut')]
        [string]$DEP,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DisablePoShV2,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DisableScheduledTask,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DisableService,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$EnableLog,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Mitigation
    )

    switch ($PSBoundParameters.Keys) {
        ApplyGPO {
            $GPO = @{}
            ($ApplyGPO | ConvertTo-Json | ConvertFrom-Json).psobject.properties | ForEach-Object { $GPO[$_.Name] = $_.Value }
            $GPOString = $(foreach ($kvp in $GPO.GetEnumerator()) { $kvp.Key + ':' + $kvp.Value }) -join ', '
            Write-Verbose "Option Selected: ApplyGPO"
            Write-Verbose "Passing GPOs: $GPOString"
            Invoke-LocalGPO @GPO -WhatIf:$WhatIfPreference
        }
        DEP {
            Write-Verbose "Option Selected: DEP"
            Set-DEP -Policy $DEP -WhatIf:$WhatIfPreference
        }
        DisablePoShV2 {
            if ($PSCmdlet.ShouldProcess("localhost", "Disable-PoShV2")) {
                Write-Verbose "Option Selected: DisablePoshV2"
                Disable-PoShV2 -WhatIf:$WhatIfPreference
            }
        }
        DisableScheduledTask {
            Write-Verbose "Option Selected: DisableScheduledTasks"
            Set-ScheduledTaskDisabled -WhatIf:$WhatIfPreference
        }
        DisableService {
            Write-Verbose "Option Selected: DisableServices"
            Set-ServicesDisabled -WhatIf:$WhatIfPreference
        }
        EnableLog {
            Write-Verbose "Option Selected: EnableLog"
            Enable-EventLog -LogName $EnableLog -WhatIf:$WhatIfPreference
        }
        Mitigation {
            Write-Verbose "Option Selected: Mitigation"
            foreach ($Mitigate in $Mitigation) {
                if ($PSCmdlet.ShouldProcess("$Mitigate", "Mitigate")) {
                    Write-Verbose "Enabling Mitigation: $Mitigate"
                }
            }
            # Call script/function
        }

    }
}
