function Get-STIGComputerInfo {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        $ComputerInfo = Get-ComputerInfo
        $Hashtable = [ordered]@{
            CsManufacturer = $ComputerInfo.CsManufacturer                                                   #Dell Inc.
            CsModel = $ComputerInfo.CsModel                                                                 #Latitude E5570
            WindowsProductName = $ComputerInfo.WindowsProductName                                           #Professional
            WindowsEditionId = $ComputerInfo.WindowsEditionId                                               #Windows 10 Pro
            OsName = $ComputerInfo.OsName                                                                   #Microsoft Windows 10 Pro
            WindowsVersion = $ComputerInfo.WindowsVersion                                                   #1909 etc
            OsVersion = $ComputerInfo.OsVersion                                                             #10.0.19042
            OsBuildNumber = $ComputerInfo.OsBuildNumber                                                     #19042
            BiosFirmwareType = $ComputerInfo.BiosFirmwareType                                               #Uefi
            BiosManufacturer = $ComputerInfo.BiosManufacturer                                               #Dell Inc.
            BiosSeralNumber = $ComputerInfo.BiosSeralNumber
            CsDomainRole = $ComputerInfo.CsDomainRole                                                       #StandaloneWorkstation
            CsDomain = $ComputerInfo.CsDomain                                                               #WORKGROUP
            CsName = $ComputerInfo.CsName                                                                   #$env:COMPUTERNAME
            CsProcessors = $ComputerInfo.CsProcessors                                                       #{Intel(R) Core(TM) i5-6300U CPU @ 2.40GHz}
            CsPhyicallyInstalledMemory = $ComputerInfo.CsPhyicallyInstalledMemory                           #16777216
            OsArchitecture = $ComputerInfo.OsArchitecture                                                   #64-bit
            OsDataExecutionPreventionAvailable = $ComputerInfo.OsDataExecutionPreventionAvailable           #True
            OsDataExecutionPreventionDrivers = $ComputerInfo.OsDataExecutionPreventionDrivers               #True
            OsDataExecutionPreventionSupportPolicy = $ComputerInfo.OsDataExecutionPreventionSupportPolicy   #OptIn
        }
        $Hashtable
    }
    
    end {
        
    }
}