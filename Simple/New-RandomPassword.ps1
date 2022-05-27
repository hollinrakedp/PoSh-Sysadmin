function New-RandomPassword {
    param (
        [Parameter()]
        [Int]$Length = 20,
        [Parameter()]
        [Int]$NonAlphaNum = 2
    )
    Add-Type -AssemblyName System.Web
    [System.Web.Security.Membership]::GeneratePassword($Length, $NonAlphaNum)
}