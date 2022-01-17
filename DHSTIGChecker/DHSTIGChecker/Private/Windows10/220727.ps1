<#
Rule Title: Structured Exception Handling Overwrite Protection (SEHOP) must be enabled.
Severity: high
Vuln ID: V-220727
STIG ID: WN10-00-000150

Discussion:
Attackers are constantly looking for vulnerabilities in systems and applications. Structured Exception Handling Overwrite Protection (SEHOP) blocks exploits that use the Structured Exception Handling overwrite technique, a common buffer overflow attack.


Check Content:
This is applicable to Windows 10 prior to v1709.

Verify SEHOP is turned on.

If the following registry value does not exist or is not configured as specified, this is a finding.

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SYSTEM\CurrentControlSet\Control\Session Manager\kernel\

Value Name: DisableExceptionChainValidation

Value Type: REG_DWORD
Value: 0x00000000 (0)

#>

$AppliesTo = '1507','1511','1607', '1703', '1709'

if (!($AppliesTo -contains $ComputerInfo.WindowsVersion)) {
    'Not Applicable'
}

$Params = @{
    Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel\"
    Name = "DisableExceptionChainValidation"
    ExpectedValue = 0
}

Compare-RegKeyValue @Params