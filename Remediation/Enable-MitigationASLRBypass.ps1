function Enable-MitigationASLRBypass {
    <#
    .SYNOPSIS
    Enable the ASLR Bypass Mitigation for Internet Explorer based on MS15-124.

    .DESCRIPTION
    This function enables the ASLR Bypass Mitigation for Internet Explorer based on the security update MS15-124.
    It modifies the registry settings for FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING.

    .NOTES
    Name        : Enable-MitigationASLRBypass
    Author      : Darren Hollinrake
    Version     : 2.0
    DateCreated : 2022-05-07
    DateUpdated : 2024-01-22

    .LINK
    https://docs.microsoft.com/en-us/security-updates/SecurityBulletins/2015/ms15-124#internet-explorer-aslr-bypass--cve-2015-6161--

    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $registryParams = @{
        Path  = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING"
        Name  = "iexplorer.exe"
        Value = 1
        Type  = "DWord"
        Force = $true
    }

    if ($PSCmdlet.ShouldProcess("FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING (x86)")) {
        Set-ItemProperty @registryParams
    }

    $osArchitecture = (Get-CimInstance Win32_OperatingSystem).OSArchitecture

    if ($osArchitecture -eq '64-bit') {
        $registryParams['Path'] = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING"
        if ($PSCmdlet.ShouldProcess("FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING (x64)")) {
            Set-ItemProperty @registryParams
        }
    }
}