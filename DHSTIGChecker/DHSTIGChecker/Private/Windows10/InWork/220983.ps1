<#
Rule Title: The Take ownership of files or other objects user right must only be assigned to the Administrators group.
Severity: medium
Vuln ID: V-220983
STIG ID: WN10-UR-000165

Discussion:
Inappropriate granting of user rights can provide system, administrative, and other high level capabilities.

Accounts with the "Take ownership of files or other objects" user right can take ownership of objects and make changes.


Check Content:
Verify the effective setting in Local Group Policy Editor.
Run "gpedit.msc".

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

If any groups or accounts other than the following are granted the "Take ownership of files or other objects" user right, this is a finding:

Administrators

#>
