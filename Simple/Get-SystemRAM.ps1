function Get-SystemRAM {
    <#
    .SYNOPSIS
    Get information about RAM in the system, including individual module sizes.

    .DESCRIPTION
    This function retrieves information about the total RAM in the system and the individual size of each RAM module.

    .NOTES
    Name        : Get-SystemRAM
    Author      : Darren Hollinrake
    Version     : 2.0
    DateCreated : 2021-08-02
    DateUpdated : 2024-01-22

    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Name", "Server")]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = @($env:COMPUTERNAME)
    )

    begin {}

    process {
        foreach ($Computer in $ComputerName) {
            try {
                if ($Computer -eq $env:COMPUTERNAME) {
                    # Local Computer
                    $Modules = Get-CimInstance -ClassName Win32_PhysicalMemory -ErrorAction Stop
                }
                else {
                    # Remote Computer
                    $Modules = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $Computer -ErrorAction Stop
                }
            
                $TotalRAM = [math]::Round(($Modules | Measure-Object Capacity -Sum).Sum / 1GB, 2)

                $ModuleInfo = foreach ($Module in $Modules) {
                    $ModuleSize = [math]::Round($Module.Capacity / 1GB, 2)
                    [PSCustomObject]@{
                        Slot          = $Module.DeviceLocator
                        Manufacturer  = $Module.Manufacturer
                        PartNumber    = $Module.PartNumber
                        SN            = $Module.SerialNumber
                        'Size (GB)'   = $ModuleSize
                        'Speed (MHz)' = $Module.Speed
                    }
                }

                $RamInfoObj = [PSCustomObject]@{
                    ComputerName     = $Computer
                    'Total RAM (GB)' = $TotalRAM
                    'Module Count'   = $Modules.Count
                    'Module Info'    = $ModuleInfo
                }

                # Customize default display properties
                $DefaultDisplaySet = 'ComputerName', 'Total RAM (GB)', 'Module Count'
                $DefaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$DefaultDisplaySet)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplayPropertySet)
                $RamInfoObj | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                $RamInfoObj
            }
            catch {
                Write-Error "Failed to retrieve RAM information on computer $Computer. $_"
            }
        }
    }

    end {}
}
