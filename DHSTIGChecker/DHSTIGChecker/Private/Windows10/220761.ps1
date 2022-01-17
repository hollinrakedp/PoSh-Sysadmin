<#
Rule Title: Windows 10 must be configured to audit Object Access - File Share failures.
Severity: medium
Vuln ID: V-220761
STIG ID: WN10-AU-000081

Discussion:
Maintaining an audit trail of system activity logs can help identify configuration errors, troubleshoot service disruptions, and analyze compromises that have occurred, as well as detect attacks. Audit logs are necessary to provide a trail of evidence in case the system or network is compromised. Collecting this data is essential for analyzing the security of information assets and detecting signs of suspicious and unexpected behavior.

Auditing file shares records events related to connection to shares on a system including system shares such as C$.


Check Content:
Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (WN10-SO-000030) for the detailed auditing subcategories to be effective.

Use the AuditPol tool to review the current Audit Policy configuration:

Open PowerShell or a Command Prompt with elevated privileges ("Run as Administrator").

Enter "AuditPol /get /category:*"

Compare the AuditPol settings with the following:

Object Access >> File Share - Failure

If the system does not audit the above, this is a finding.

#>

$Category = "File Share"
$Setting = "Failure"

$AuditSetting = $AuditPolicy | Where-Object {$_.Subcategory -contains "$Category"}

if ($AuditSetting.'Inclusion Setting' -match $Setting) {
    $true
}
else {
    $false
}