<#
Rule Title: The Create a pagefile user right must only be assigned to the Administrators group.
Severity: medium
Vuln ID: V-220962
STIG ID: WN10-UR-000040

Discussion:
Inappropriate granting of user rights can provide system, administrative, and other high level capabilities.

Accounts with the "Create a pagefile" user right can change the size of a pagefile, which could affect system performance.


Check Content:
Verify the effective setting in Local Group Policy Editor.
Run "gpedit.msc".

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

If any groups or accounts other than the following are granted the "Create a pagefile" user right, this is a finding:

Administrators

#>
