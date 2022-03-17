function New-RandomPassword {
    param (
        [Parameter()]
        [Int]$Length = 20,
        [Parameter()]
        [Int]$NonAlphaNum = 2
    )
    [System.Web.Security.Membership]::GeneratePassword($Length, $NonAlphaNum)
}