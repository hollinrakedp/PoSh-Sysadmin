Function Get-DEP {
    <#
    .SYNOPSIS
    Displays the configured DEP value.

    .DESCRIPTION
    Displays the configured DEP value.

    .NOTES
    Name         - Get-DEP
    Version      - 0.1
    Author       - Darren Hollinrake
    Date Created - 2022-01-16
    Date Updated - 

    .EXAMPLE
    Get-DEP
    OptOut

    #>
    [CmdletBinding()]
    Param(
    )
    $DEP = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object DataExecutionPrevention_SupportPolicy
    switch ($DEP.DataExecutionPrevention_SupportPolicy) {
        0 { "AlwaysOff" }
        1 { "AlwaysOn" }
        2 { "OptIn" }
        3 { "OptOut" }
    }
}