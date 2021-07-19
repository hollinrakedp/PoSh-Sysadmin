function Get-SystemUptime {
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