<#
Rule Title: The system must be configured to audit System - System Integrity successes.
Severity: medium
Vuln ID: V-220778
STIG ID: WN10-AU-000160

Discussion:
Maintaining an audit trail of system activity logs can help identify configuration errors, troubleshoot service disruptions, and analyze compromises that have occurred, as well as detect attacks.  Audit logs are necessary to provide a trail of evidence in case the system or network is compromised.  Collecting this data is essential for analyzing the security of information assets and detecting signs of suspicious and unexpected behavior.

System Integrity records events related to violations of integrity to the security subsystem.


Check Content:
Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (WN10-SO-000030) for the detailed auditing subcategories to be effective.

Use the AuditPol tool to review the current Audit Policy configuration:
Open a Command Prompt with elevated privileges ("Run as Administrator").
Enter "AuditPol /get /category:*".

Compare the AuditPol settings with the following.  If the system does not audit the following, this is a finding:

System >> System Integrity - Success

#>

$Local:Category = "System Integrity"
$Local:Setting = "Success"

$Local:AuditSetting = $AuditPolicy | Where-Object {$_.Subcategory -contains "$Local:Category"}

if ($Local:AuditSetting.'Inclusion Setting' -match $Local:Setting) {
    $true
}
else {
    $false
}