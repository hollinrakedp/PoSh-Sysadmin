<#
Rule Title: The system must be configured to audit Logon/Logoff - Logon successes.
Severity: medium
Vuln ID: V-220759
STIG ID: WN10-AU-000075

Discussion:
Maintaining an audit trail of system activity logs can help identify configuration errors, troubleshoot service disruptions, and analyze compromises that have occurred, as well as detect attacks.  Audit logs are necessary to provide a trail of evidence in case the system or network is compromised.  Collecting this data is essential for analyzing the security of information assets and detecting signs of suspicious and unexpected behavior.

Logon records user logons. If this is an interactive logon, it is recorded on the local system. If it is to a network share, it is recorded on the system accessed.


Check Content:
Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (WN10-SO-000030) for the detailed auditing subcategories to be effective.

Use the AuditPol tool to review the current Audit Policy configuration:
Open a Command Prompt with elevated privileges ("Run as Administrator").
Enter "AuditPol /get /category:*".

Compare the AuditPol settings with the following.  If the system does not audit the following, this is a finding:

Logon/Logoff >> Logon - Success

#>

$Category = "Logon"
$Setting = "Success"

$AuditSetting = $AuditPolicy | Where-Object {$_.Subcategory -contains "$Category"}

if ($AuditSetting.'Inclusion Setting' -match $Setting) {
    $true
}
else {
    $false
}