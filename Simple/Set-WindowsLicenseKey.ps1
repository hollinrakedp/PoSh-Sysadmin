function Set-WindowsLicenseKey {
    param (
        [Parameter()]
        [string]$ComputerName,
        [Parameter()]
        [ValidatePattern("^\S{5}-\S{5}-\S{5}-\S{5}-\S{5}")]
        [string]$ProductKey = "NPPR9-FWDCX-D2C8J-H872K-2YT43"
    )
    if ([string]::IsNullOrEmpty($ComputerName)) {
        $(Get-WmiObject SoftwareLicensingService).InstallProductKey($ProductKey)
    }
    else {
        Invoke-Command -ComputerName $ComputerName { $(Get-WmiObject SoftwareLicensingService).InstallProductKey($Using:ProductKey) }
    }
}