<#
Rule Title: The Windows SMB server must be configured to always perform SMB packet signing.
Severity: medium
Vuln ID: V-220927
STIG ID: WN10-SO-000120

Discussion:
The server message block (SMB) protocol provides the basis for many network operations.  Digitally signed SMB packets aid in preventing man-in-the-middle attacks.  If this policy is enabled, the SMB server will only communicate with an SMB client that performs SMB packet signing.


Check Content:
If the following registry value does not exist or is not configured as specified, this is a finding:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SYSTEM\CurrentControlSet\Services\LanManServer\Parameters\

Value Name: RequireSecuritySignature

Value Type: REG_DWORD
Value: 1

#>

$Params = @{
    Path          = "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters\"
    Name          = "RequireSecuritySignature"
    ExpectedValue = 1
}

Compare-RegKeyValue @Params