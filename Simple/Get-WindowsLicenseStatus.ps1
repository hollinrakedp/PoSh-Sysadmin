function Get-WindowsLicenseStatus {
    param (
        [Parameter()]
        [string]$ComputerName
    )
    process {
        if ([string]::IsNullOrEmpty($ComputerName)) {
            $Result = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object -Property LicenseStatus   
        }
        else {
            $Result = Invoke-Command -ComputerName $ComputerName { Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object -Property LicenseStatus }   
        }
        $Value = switch ($Result.LicenseStatus) {
            0 { "Unlicensed" }
            1 { "Licensed" }
            2 { "OOBGrace" }
            3 { "OOTGrace" }
            4 { "NonGenuineGrace" }
            5 { "Notification" }
            6 { "ExtendedGrace" }
        }
        $Value
    }
}