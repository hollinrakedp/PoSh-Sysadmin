Function Set-DEP {
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
    Param(
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [ValidateSet('AlwaysOff', 'AlwaysOn', 'OptIn', 'OptOut')]
        [Alias("Value")]
        [string[]]$Policy
    )
    $SetValue = switch ($Policy) {
        AlwaysOff { 0 }
        AlwaysOn { 1 }
        OptIn { 2 }
        OptOut { 3 }
    }
    if ($PSCmdlet.ShouldProcess("localhost", "Set-DEP $Policy")) {
        $CurrentValue = (Get-CimInstance -ClassName Win32_OperatingSystem).DataExecutionPrevention_SupportPolicy
        Write-Verbose "DEP Current Value = $CurrentValue"
    
        if ($SetValue -eq $CurrentValue) {
            Write-Output "DEP is already set to $CurrentValue"
            return
        }
        Write-Verbose "Setting DEP to $Policy"
        BCDEDIT /set "{current}" nx $Policy
    }
}