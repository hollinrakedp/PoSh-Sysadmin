Function Get-DEP {
    [cmdletbinding()]
    Param(
    )
    $DEP = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object DataExecutionPrevention_SupportPolicy
    $Value = switch ($DEP.DataExecutionPrevention_SupportPolicy) {
        0 { "AlwaysOff" }
        1 { "AlwaysOn" }
        2 { "OptIn" }
        3 { "OptOut" }
    }
    $Value
}