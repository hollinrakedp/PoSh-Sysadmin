<#
Rule Title: Explorer Data Execution Prevention must be enabled.
Severity: medium
Vuln ID: V-220837
STIG ID: WN10-CC-000215

Discussion:
Data Execution Prevention (DEP) provides additional protection by performing  checks on memory to help prevent malicious code from running.  This setting will prevent Data Execution Prevention from being turned off for File Explorer.


Check Content:
The default behavior is for data execution prevention to be turned on for file explorer.

If the registry value name below does not exist, this is not a finding.

If it exists and is configured with a value of "0", this is not a finding.

If it exists and is configured with a value of "1", this is a finding.

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\Explorer\

Value Name: NoDataExecutionPrevention

Value Type: REG_DWORD
Value: 0 (or if the Value Name does not exist)

#>

$Params = @{
    Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\"
    Name = "NoDataExecutionPrevention"
    ExpectedValue = 0
}

if (!(Test-RegKeyValueExists -Path $Params.Path -Name $Params.Name)) {
    return $true
}

Compare-RegKeyValue @Params