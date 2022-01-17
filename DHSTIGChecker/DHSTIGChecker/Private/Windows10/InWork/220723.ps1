<#
Rule Title: Software certificate installation files must be removed from Windows 10.
Severity: medium
Vuln ID: V-220723
STIG ID: WN10-00-000130

Discussion:
Use of software certificates and their accompanying installation files for end users to access resources is less secure than the use of hardware-based certificates.


Check Content:
Search all drives for *.p12 and *.pfx files.

If any files with these extensions exist, this is a finding.

This does not apply to server-based applications that have a requirement for .p12 certificate files (e.g., Oracle Wallet Manager) or Adobe PreFlight certificate files. Some applications create files with extensions of .p12 that are not certificate installation files. Removal of non-certificate installation files from systems is not required. These must be documented with the ISSO.

#>
