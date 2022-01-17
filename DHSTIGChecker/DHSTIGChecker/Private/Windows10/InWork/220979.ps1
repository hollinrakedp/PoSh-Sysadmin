<#
Rule Title: The Modify firmware environment values user right must only be assigned to the Administrators group.
Severity: medium
Vuln ID: V-220979
STIG ID: WN10-UR-000140

Discussion:
Inappropriate granting of user rights can provide system, administrative, and other high level capabilities.

Accounts with the "Modify firmware environment values" user right can change hardware configuration environment variables. This could result in hardware failures or a DoS.


Check Content:
Verify the effective setting in Local Group Policy Editor.
Run "gpedit.msc".

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

If any groups or accounts other than the following are granted the "Modify firmware environment values" user right, this is a finding:

Administrators

#>
