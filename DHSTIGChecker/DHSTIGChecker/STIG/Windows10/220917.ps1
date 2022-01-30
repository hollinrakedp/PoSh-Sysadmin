<#
Rule Title: The computer account password must not be prevented from being reset.
Severity: low
Vuln ID: V-220917
STIG ID: WN10-SO-000050

Discussion:
Computer account passwords are changed automatically on a regular basis.  Disabling automatic password changes can make the system more vulnerable to malicious access.  Frequent password changes can be a significant safeguard for your system.  A new password for the computer account will be generated every 30 days.


Check Content:
If the following registry value does not exist or is not configured as specified, this is a finding:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\

Value Name: DisablePasswordChange

Value Type: REG_DWORD
Value: 0

#>

$Params = @{
    Path          = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\"
    Name          = "DisablePasswordChange"
    ExpectedValue = 0
}

Compare-RegKeyValue @Params