<#
Rule Title: The system must be configured to audit Detailed Tracking - PNP Activity successes.
Severity: medium
Vuln ID: V-220753
STIG ID: WN10-AU-000045

Discussion:
Maintaining an audit trail of system activity logs can help identify configuration errors, troubleshoot service disruptions, and analyze compromises that have occurred, as well as detect attacks. Audit logs are necessary to provide a trail of evidence in case the system or network is compromised. Collecting this data is essential for analyzing the security of information assets and detecting signs of suspicious and unexpected behavior.

Plug and Play activity records events related to the successful connection of external devices.


Check Content:
Security Option "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings" must be set to "Enabled" (WN10-SO-000030) for the detailed auditing subcategories to be effective. 

Use the AuditPol tool to review the current Audit Policy configuration:
Open a Command Prompt with elevated privileges ("Run as Administrator").
Enter "AuditPol /get /category:*"

Compare the AuditPol settings with the following.  If the system does not audit the following, this is a finding:

Detailed Tracking >> Plug and Play Events - Success

#>

$Category = "Plug and Play Events"
$Setting = "Success"

$AuditSetting = $Script:AuditPolicy | Where-Object {$_.Subcategory -contains "$Category"}

if ($AuditSetting.'Inclusion Setting' -match $Setting) {
    $true
}
else {
    $false
}