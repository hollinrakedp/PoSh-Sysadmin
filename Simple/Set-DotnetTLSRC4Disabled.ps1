<#
.SYNOPSIS
Disable TLS RC4 cipher in .NET.

.DESCRIPTION
The script sets the registry keys necessary to disable the TLS RC4 cipher in .NET.

.NOTES   
Name       : Set-DotnetTLSRC4Disabled.ps1
Author     : Darren Hollinrake
Version    : 0.1
DateCreated: 2018-11-08
DateUpdated: 

#>

# For 32-bit applications on 32-bit systems and 64-bit applications on 64-bit systems.
REG ADD "HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 1 /f
# For 32-bit applications on 64-bit systems
REG ADD "HKLM\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 1 /f
