Function Get-DriveSpace {
    [cmdletbinding()]
    Param(
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [Alias("Name", "Server")]
        [string[]]$ComputerName = "localhost"
    )
    <#
    Disk Type
    1 - No root directory
    2 - Removable Disk
    3 - Local Hard Disk
    4 - Network Disk
    5 - Compact Disc
    6 - RAM Disk
    #>
    begin{

    }

    process {
        foreach ($Computer in $ComputerName) {
            Get-CimInstance -ComputerName "$Computer" -ClassName Win32_LogicalDisk | Select-Object SystemName, DeviceID, @{Name = "Size(GB)"; Expression = { $_.Size / 1gb -as [int] } }, @{Name = "Used(GB)"; Expression = { ($_.Size - $_.FreeSpace) / 1gb -as [int] } }, @{Name = "Free(GB)"; Expression = { $_.FreeSpace / 1gb -as [int] } }, @{Name = "% Free"; Expression = { $_.FreeSpace / $_.Size * 100 -as [int] } }    
        }
        
    }

    end{

    }

}