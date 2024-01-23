function Get-WindowsLicenseStatus {
    <#
    .SYNOPSIS
    Get the license status of the Windows operating system on a local or remote computer.

    .DESCRIPTION
    This function retrieves and interprets the license status of the Windows operating system.
    It queries the SoftwareLicensingProduct class to obtain licensing information and converts
    the numeric license status into human-readable strings.

    .NOTES
    Name        : Get-WindowsLicenseStatus
    Author      : Darren Hollinrake
    Version     : 1.1
    DateCreated : 2022-05-07
    DateUpdated : 

    .PARAMETER ComputerName
    Specifies the target computer. If not provided, the function assumes the local computer.

    .OUTPUTS
    System.String

    .EXAMPLE
    Get-WindowsLicenseStatus
    Get the license status of the Windows operating system on the local computer.

    #>
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

        switch ($Result.LicenseStatus) {
            0 { "Unlicensed" }
            1 { "Licensed" }
            2 { "OOBGrace" }
            3 { "OOTGrace" }
            4 { "NonGenuineGrace" }
            5 { "Notification" }
            6 { "ExtendedGrace" }
        }
    }
}