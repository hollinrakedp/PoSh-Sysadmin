function Enable-MitigationASLRBypass {
    # https://docs.microsoft.com/en-us/security-updates/SecurityAdvisories/2015/3009008
    # https://cloudacademy.com/blog/how-to-fix-poodle-on-windows-server-2012/

    if ((Get-CimInstance Win32_OperatingSystem).Caption -eq "Windows Server 2012 R2") {
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel\Protocols\SSL 3.0\Client" /v DisabledByDefault /t REG_DWORD /d 1 /f
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel\Protocols\SSL 3.0\Server" /v Enabled /t REG_DWORD /d 0 /f
    } else {
        Write-Output "This Mitigation is only needed for Server 2012 R2."
    }
}