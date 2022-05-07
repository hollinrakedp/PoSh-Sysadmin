function Invoke-WindowsLicenseRefresh {
    param (
        [Parameter()]
        [string]$ComputerName
    )
    if ([string]::IsNullOrEmpty($ComputerName)) {
        $(Get-WmiObject SoftwareLicensingService).RefreshLicenseStatus()
    }
    else {
        $(Get-WmiObject SoftwareLicensingService).RefreshLicenseStatus()
    }
}