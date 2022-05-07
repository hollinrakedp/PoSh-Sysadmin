Function Get-SystemDriveInfo {
    [CmdletBinding()]
    param()
    begin {}
    process {
        $LogicalDisk = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object SystemName, DeviceID, Size, FreeSpace, DriveType

        foreach ($Disk in $LogicalDisk) {
            $DriveType = switch ($Disk.DriveType) {
                1 { "NoRootDirectory" }
                2 { "Removable Disk" }
                3 { "Local Hard Disk" }
                4 { "Network Disk" }
                5 { "Compact Disc" }
                6 { "RAM Disk" }
                Default { "Unknown" }
            }

            $DiskInfo = [PSCustomObject]@{
                ComputerName = $Disk.SystemName
                DriveType    = $DriveType
                Device       = $Disk.DeviceID
                'Size (GB)'  = $Disk.Size / 1gb -as [int]
                'Used (GB)'  = ($Disk.Size - $Disk.FreeSpace) / 1gb -as [int]
                'Free (GB)'  = $Disk.FreeSpace / 1gb -as [int]
                'Free (%)'   = $Disk.FreeSpace / $Disk.Size * 100 -as [int]
            }
            $DiskInfo
        }
    }
    end {}
}