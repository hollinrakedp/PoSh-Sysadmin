function Show-HyperthreadingStatus {
    <#
    .SYNOPSIS
    Show if Hyperthreading is enabled

    .DESCRIPTION
    

    .NOTES
    Name        : Show-HyperthreadingStatus
    Author      : Darren Hollinrake
    Version     : 0.1
    DateCreated : 2021-12-29
    DateUpdated : 

    #>
    [CmdletBinding()]
    param ()
    
    begin {}
    
    process {
        $Processor = Get-CimInstance Win32_Processor
        $Processor.NumberOfLogicalProcessors -gt $Processor.NumberOfCores
    }
    
    end {}
}