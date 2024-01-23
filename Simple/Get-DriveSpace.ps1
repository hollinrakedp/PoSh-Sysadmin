function Get-DriveSpace {
    <#
    .SYNOPSIS
    Get information about disk drives on the local system or specified remote systems.

    .DESCRIPTION
    This function retrieves information about disk drives on the local machine or specified remote systems and outputs details such as drive letter, size, used space, free space, and free space percentage.

    Only local and removable disks are enumerated.

    .NOTES
    Name        : Get-DriveSpace
    Author      : Darren Hollinrake
    Version     : 2.0
    DateCreated : 2021-08-02
    DateUpdated : 2024-01-22

    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Name", "Server")]
        [string[]]$ComputerName = @($env:COMPUTERNAME)
    )

    begin {}

    process {
        foreach ($Computer in $ComputerName) {
            if ($Computer -eq $env:COMPUTERNAME) {
                # Local Computer
                $DiskDrives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3 OR DriveType=2"
            }
            else {
                # Remote Computer
                $DiskDrives = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $computer -Filter "DriveType=3 OR DriveType=2"
            }
            foreach ($Drive in $DiskDrives) {
                $DriveLetter = $Drive.DeviceID
                $SizeGB = [math]::Round($Drive.Size / 1GB)
                $UsedSpaceGB = [math]::Round(($Drive.Size - $Drive.FreeSpace) / 1GB)
                $FreeSpaceGB = [math]::Round($Drive.FreeSpace / 1GB)
                $FreeSpacePercentage = [math]::Round(($Drive.FreeSpace / $Drive.Size) * 100, 2)

                $DriveType = switch ($Drive.DriveType) {
                    0 { 'Unknown' }
                    1 { 'No Root Directory' }
                    2 { 'Removable Disk' }
                    3 { 'Local Disk' }
                    4 { 'Network Drive' }
                    5 { 'Compact Disc' }
                    6 { 'RAM Disk' }
                }

                $DiskInfoObj = [PSCustomObject]@{
                    ComputerName     = $Computer
                    DriveType        = $DriveType
                    Drive            = $DriveLetter
                    'Size (GB)'      = $SizeGB
                    'Used (GB)'      = $UsedSpaceGB
                    'Free (GB)'      = $FreeSpaceGB
                    'Free (%)'       = $FreeSpacePercentage
                    'DriveTypeValue' = $Drive.DriveType
                }

                # Customize default display properties
                $defaultDisplaySet = 'ComputerName', 'Drive', 'Free (GB)', 'DriveType'
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $DiskInfoObj | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                $DiskInfoObj

            }
        }
    }
    
    end {}
}
