<#
Rule Title: The maximum age for machine account passwords must be configured to 30 days or less.
Severity: low
Vuln ID: V-220918
STIG ID: WN10-SO-000055

Discussion:
Computer account passwords are changed automatically on a regular basis.  This setting controls the maximum password age that a machine account may have.  This setting must be set to no more than 30 days, ensuring the machine changes its password monthly.


Check Content:
This is the default configuration for this setting (30 days).

If the following registry value does not exist or is not configured as specified, this is a finding:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\

Value Name: MaximumPasswordAge

Value Type: REG_DWORD
Value: 0x0000001e (30)  (or less, excluding 0)

#>
