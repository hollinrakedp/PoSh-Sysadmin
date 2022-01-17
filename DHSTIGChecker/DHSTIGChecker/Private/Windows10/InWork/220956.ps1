<#
Rule Title: The Access Credential Manager as a trusted caller user right must not be assigned to any groups or accounts.
Severity: medium
Vuln ID: V-220956
STIG ID: WN10-UR-000005

Discussion:
Inappropriate granting of user rights can provide system, administrative, and other high level capabilities.

Accounts with the "Access Credential Manager as a trusted caller" user right may be able to retrieve the credentials of other accounts from Credential Manager.


Check Content:
Verify the effective setting in Local Group Policy Editor.
Run "gpedit.msc".

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

If any groups or accounts are granted the "Access Credential Manager as a trusted caller" user right, this is a finding.

#>
