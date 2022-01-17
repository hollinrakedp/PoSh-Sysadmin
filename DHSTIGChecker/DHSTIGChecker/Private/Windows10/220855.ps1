<#
Rule Title: Indexing of encrypted files must be turned off.
Severity: medium
Vuln ID: V-220855
STIG ID: WN10-CC-000305

Discussion:
Indexing of encrypted files may expose sensitive data.  This setting prevents encrypted files from being indexed.


Check Content:
If the following registry value does not exist or is not configured as specified, this is a finding:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\Windows Search\

Value Name: AllowIndexingEncryptedStoresOrItems

Value Type: REG_DWORD
Value: 0

#>

$Params = @{
    Path          = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\"
    Name          = "AllowIndexingEncryptedStoresOrItems"
    ExpectedValue = 0
}

Compare-RegKeyValue @Params