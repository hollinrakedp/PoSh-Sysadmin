<#
Rule Title: Users must be notified if a web-based program attempts to install software.
Severity: medium
Vuln ID: V-220858
STIG ID: WN10-CC-000320

Discussion:
Web-based programs may attempt to install malicious software on a system.  Ensuring users are notified if a web-based program attempts to install software allows them to refuse the installation.


Check Content:
The default behavior is for Internet Explorer to warn users and select whether to allow or refuse installation when a web-based program attempts to install software on the system.

If the registry value name below does not exist, this is not a finding.

If it exists and is configured with a value of "0", this is not a finding.

If it exists and is configured with a value of "1", this is a finding.

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\Installer\

Value Name: SafeForScripting

Value Type: REG_DWORD
Value: 0 (or if the Value Name does not exist)

#>

$Params = @{
    Path          = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer\"
    Name          = "SafeForScripting"
    ExpectedValue = 0
}

if (!(Test-RegKeyValueExists -Path $Params.Path -Name $Params.Name)) {
    return $true
}

Compare-RegKeyValue @Params