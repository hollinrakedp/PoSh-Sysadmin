<#
Rule Title: Windows 10 must be configured to audit Object Access - Other Object Access Events failures.
Severity: medium
Vuln ID: V-220764
STIG ID: WN10-AU-000084

Discussion:
Maintaining an audit trail of system activity logs can help identify configuration errors, troubleshoot service disruptions, and analyze compromises that have occurred, as well as detect attacks. Audit logs are necessary to provide a trail of evidence in case the system or network is compromised. Collecting this data is essential for analyzing the security of information assets and detecting signs of suspicious and unexpected behavior.

Auditing for other object access records events related to the management of task scheduler jobs and COM+ objects.


Check Content:
Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (WN10-SO-000030) for the detailed auditing subcategories to be effective.

Use the AuditPol tool to review the current Audit Policy configuration:

Open PowerShell or a Command Prompt with elevated privileges ("Run as Administrator").

Enter "AuditPol /get /category:*"

Compare the AuditPol settings with the following:

Object Access >> Other Object Access Events - Failure

If the system does not audit the above, this is a finding.

#>

$Category = "Other Object Access Events"
$Setting = "Failure"

$AuditSetting = $Script:AuditPolicy | Where-Object {$_.Subcategory -contains "$Category"}

if ($AuditSetting.'Inclusion Setting' -match $Setting) {
    $true
}
else {
    $false
}