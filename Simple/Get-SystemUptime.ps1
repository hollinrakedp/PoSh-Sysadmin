function Get-SystemUptime {
    $LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    (New-TimeSpan -Start $LastBootUpTime).ToString("dd' days, 'hh' hours, 'mm' minutes, 'ss' seconds'")
}