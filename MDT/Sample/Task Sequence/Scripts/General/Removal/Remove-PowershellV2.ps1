<#
Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Remove PowerShell v2
PowerShell script: %SCRIPTROOT%\General\Removal\Remove-PowerShellV2.ps1
#>
If ((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root).State -eq "Disabled"){
    Write-Host "Feature is already disabled. Nothing to do..."
}
Else {
    Write-Host "Disabling Feature $((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root).DisplayName)"
    Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -Verbose
}
