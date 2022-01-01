function Enable-MitigationASLRBypass {
    # MS15-124
    # https://docs.microsoft.com/en-us/security-updates/SecurityBulletins/2015/ms15-124#internet-explorer-aslr-bypass--cve-2015-6161--

    if ($(Get-CimInstance win32_operatingsystem).OSArchitecture -eq '64-bit') {
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING\" /v "iexplorer.exe" /t REG_DWORD /d 1 /f
    }

    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING\" /v "iexplorer.exe" /t REG_DWORD /d 1 /f
}