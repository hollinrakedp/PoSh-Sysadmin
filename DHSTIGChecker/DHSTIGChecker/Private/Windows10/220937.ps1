<#
Rule Title: The system must be configured to prevent the storage of the LAN Manager hash of passwords.
Severity: high
Vuln ID: V-220937
STIG ID: WN10-SO-000195

Discussion:
The LAN Manager hash uses a weak encryption algorithm and there are several tools available that use this hash to retrieve account passwords.  This setting controls whether or not a LAN Manager hash of the password is stored in the SAM the next time the password is changed.


Check Content:
If the following registry value does not exist or is not configured as specified, this is a finding:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SYSTEM\CurrentControlSet\Control\Lsa\

Value Name: NoLMHash

Value Type: REG_DWORD
Value: 1

#>

$Params = @{
    Path          = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\"
    Name          = "NoLMHash"
    ExpectedValue = 1
}

Compare-RegKeyValue @Params