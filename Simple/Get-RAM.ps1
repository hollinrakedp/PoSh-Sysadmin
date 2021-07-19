Function Get-RAM {
    [cmdletbinding()]
    Param(
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [Alias("Name", "Server")]
        [string[]]$ComputerName = "localhost"
    )

    begin{

    }

    process {
        foreach ($Computer in $ComputerName) {
            $RAM = Get-CimInstance -ComputerName "$Computer" -ClassName Win32_PhysicalMemory | Measure-Object Capacity -Sum
            $RAM | Select-Object @{Name="RAM(GB)";Expression={[Math]::Round($RAM.Sum / 1GB)}}
        }
    }

    end{

    }
}