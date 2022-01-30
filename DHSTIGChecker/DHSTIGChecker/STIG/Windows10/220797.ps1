<#
Rule Title: The system must be configured to prevent Internet Control Message Protocol (ICMP) redirects from overriding Open Shortest Path First (OSPF) generated routes.
Severity: low
Vuln ID: V-220797
STIG ID: WN10-CC-000030

Discussion:
Allowing ICMP redirect of routes can lead to traffic not being routed properly.   When disabled, this forces ICMP to be routed via shortest path first.


Check Content:
If the following registry value does not exist or is not configured as specified, this is a finding:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\

Value Name: EnableICMPRedirect

Value Type: REG_DWORD
Value: 0

#>

$Params = @{
    Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\"
    Name = "EnableICMPRedirect"
    ExpectedValue = 0
}

Compare-RegKeyValue @Params