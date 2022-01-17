<#
Rule Title: The Allow log on locally user right must only be assigned to the Administrators and Users groups.
Severity: medium
Vuln ID: V-220959
STIG ID: WN10-UR-000025

Discussion:
Inappropriate granting of user rights can provide system, administrative, and other high-level capabilities.

Accounts with the "Allow log on locally" user right can log on interactively to a system.


Check Content:
Verify the effective setting in Local Group Policy Editor.

Run "gpedit.msc".

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

If any groups or accounts other than the following are granted the "Allow log on locally" user right, this is a finding:

Administrators
Users

#>
