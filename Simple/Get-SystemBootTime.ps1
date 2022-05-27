function Get-SystemBootTime {
    (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
}