<#
Rule Title: The Create global objects user right must only be assigned to Administrators, Service, Local Service, and Network Service.
Severity: medium
Vuln ID: V-220964
STIG ID: WN10-UR-000050

Discussion:
Inappropriate granting of user rights can provide system, administrative, and other high level capabilities.

Accounts with the "Create global objects" user right can create objects that are available to all sessions, which could affect processes in other users' sessions.


Check Content:
Verify the effective setting in Local Group Policy Editor.
Run "gpedit.msc".

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

If any groups or accounts other than the following are granted the "Create global objects" user right, this is a finding:

Administrators
LOCAL SERVICE
NETWORK SERVICE
SERVICE

#>
