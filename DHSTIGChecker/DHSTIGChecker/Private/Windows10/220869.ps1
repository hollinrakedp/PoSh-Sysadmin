<#
Rule Title: Windows 10 must be configured to prevent Windows apps from being activated by voice while the system is locked.
Severity: medium
Vuln ID: V-220869
STIG ID: WN10-CC-000365

Discussion:
Allowing Windows apps to be activated by voice from the lock screen could allow for unauthorized use. Requiring logon will ensure the apps are only used by authorized personnel.


Check Content:
This setting requires v1903 or later of Windows 10; it is NA for prior versions.  The setting is NA when the �Allow voice activation� policy is configured to disallow applications to be activated with voice for all users.
If the following registry value does not exist or is not configured as specified, this is a finding.

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\AppPrivacy\

Value Name: LetAppsActivateWithVoiceAboveLock

Type: REG_DWORD
Value: 0x00000002 (2)

If the following registry value exists and is configured as specified, requirement is NA. 

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\AppPrivacy\

Value Name: LetAppsActivateWithVoice

Type: REG_DWORD
Value: 0x00000002 (2)

#>

$Results = @()
$Names = @(
    "LetAppsActivateWithVoiceAboveLock",
    "LetAppsActivateWithVoice")

foreach ($Name in $Names) {
    $Params = @{
        Path          = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy\"
        Name          = "$Name"
        ExpectedValue = 2
    }
    
    $Results += Compare-RegKeyValue @Params
}

if ($Results -contains "Open") {
    "Open"
}
else {
    "Not a finding"
}