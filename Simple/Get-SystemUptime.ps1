function Get-SystemUptime {
    <#
    .SYNOPSIS
    Retrieves the system uptime or last boot time.

    .DESCRIPTION
    Returns the current system uptime or last boot time in a human-readable format.

    .NOTES
    Name        : Get-SystemUptime
    Author      : Darren Hollinrake
    Version     : 1.0
    DateCreated : 2021-08-03
    DateUpdated : 2024-01-22

    .EXAMPLE
    Get-SystemUptime
    Returns the elapsed time since the system last booted.

    .EXAMPLE
    Get-SystemUptime -BootTime
    Returns the last boot time.

    #>
    param (
        [Parameter()]
        [switch]$BootTime
    )

    $LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    switch ($BootTime) {
        True { $LastBootUpTime }
        False { (New-TimeSpan -Start $LastBootUpTime).ToString("dd' days 'hh' hours 'mm' minutes 'ss' seconds'") }
    }
}