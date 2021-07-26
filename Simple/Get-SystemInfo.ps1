function Get-SystemInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName = "localhost"
    )
    
    begin {
        $SystemInfo = @()
    }
    
    process {
        foreach ($Computer in $ComputerName) {
            $OperatingSystem = Get-CimInstance -ComputerName $Computer -ClassName Win32_OperatingSystem
            $RAM = Get-CimInstance -ComputerName $Computer -ClassName Win32_PhysicalMemory | Measure-Object Capacity -Sum
            $DiskDrive = Get-CimInstance -ComputerName $Computer -Class Win32_logicaldisk -Filter "DriveType = '3'" | Select-Object DeviceID, Size, FreeSpace
            $SystemInfoObj = [PSCustomObject]@{
                ComputerName      = $OperatingSystem.CSName
                OS                = $OperatingSystem.Caption
                'OS Version'      = $OperatingSystem.Version
                'RAM(GB)'         = ([Math]::Round($RAM.Sum / 1GB))
                'OSDriveSize(GB)' = ([Math]::Round($DiskDrive.Size / 1GB))
                'OSDriveFree(GB)' = ([Math]::Round($DiskDrive.FreeSpace / 1GB))
                LastBootUpTime    = $OperatingSystem.LastBootUpTime
            }
            $SystemInfo += $SystemInfoObj
        }

        $SystemInfo
    }
    
    end {
        
    }
}