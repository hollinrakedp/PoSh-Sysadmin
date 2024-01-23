function Set-DEP {
    <#
    .SYNOPSIS
    Sets the Data Execution Prevention (DEP) policy on the system.

    .DESCRIPTION
    This function allows you to set the DEP policy on a Windows system. DEP is a security feature that helps prevent damage from viruses and other security threats that attempt to execute code from system memory locations reserved for Windows and other authorized programs.

    .NOTES   
    Name       : Set-DEP
    Author     : Darren Hollinrake
    Version    : 1.0
    DateCreated: 2021-07-18
    DateUpdated: 2024-01-22

    #>
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
    Param(
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [ValidateSet('AlwaysOff', 'AlwaysOn', 'OptIn', 'OptOut')]
        [Alias("Value")]
        [string]$Policy
    )
    $SetValue = switch ($Policy) {
        AlwaysOff { 0 }
        AlwaysOn { 1 }
        OptIn { 2 }
        OptOut { 3 }
    }

    if ($PSCmdlet.ShouldProcess("localhost", "Set-DEP $Policy")) {
        Write-Verbose "Setting DEP to $Policy"
        $CurrentValue = (Get-CimInstance -ClassName Win32_OperatingSystem).DataExecutionPrevention_SupportPolicy
        if ($SetValue -eq $CurrentValue) {
            Write-Output "DEP is already set to $CurrentValue"
        }
        else {
            BCDEDIT /set "{current}" nx $Policy
            Write-Output "DEP has been set. Reboot the system for the change to apply."
        }
        
    }
}