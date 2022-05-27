Function Get-SystemRAM {
    [CmdletBinding()]
    param()

    begin {}
    process {
        $RAM = Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object Capacity -Sum
        $RAM | Select-Object @{Name = "RAM (GB)"; Expression = { [Math]::Round($RAM.Sum / 1GB) } }
    }
    end {}
}