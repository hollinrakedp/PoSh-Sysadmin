<# 
Run from a DC. Copies the local C:\Windows\PolicyDefinitions folder to C:\Windows\SYSVOL\domain\Policies

#>
If (!(Test-Path "C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions")){
    Write-Verbose "Central Store doesn't exist, creating it now."
    Copy-Item -Path "C:\Windows\PolicyDefinitions" -Destination "C:\Windows\SYSVOL\domain\Policies" -Recurse
}
