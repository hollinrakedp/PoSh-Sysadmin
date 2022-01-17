<#
Rule Title: Unused accounts must be disabled or removed from the system after 35 days of inactivity.
Severity: low
Vuln ID: V-220711
STIG ID: WN10-00-000065

Discussion:
Outdated or unused accounts provide penetration points that may go undetected.  Inactive accounts must be deleted if no longer necessary or, if still required, disable until needed.


Check Content:
Run "PowerShell".
Copy the lines below to the PowerShell window and enter.

"([ADSI]('WinNT://{0}' -f $env:COMPUTERNAME)).Children | Where { $_.SchemaClassName -eq 'user' } | ForEach {
   $user = ([ADSI]$_.Path)
   $lastLogin = $user.Properties.LastLogin.Value
   $enabled = ($user.Properties.UserFlags.Value -band 0x2) -ne 0x2
   if ($lastLogin -eq $null) {
      $lastLogin = 'Never'
   }
   Write-Host $user.Name $lastLogin $enabled 
}"

This will return a list of local accounts with the account name, last logon, and if the account is enabled (True/False).
For example: User1  10/31/2015  5:49:56  AM  True

Review the list to determine the finding validity for each account reported.

Exclude the following accounts:
Built-in administrator account (Disabled, SID ending in 500)
Built-in guest account (Disabled, SID ending in 501)
Built-in DefaultAccount (Disabled, SID ending in 503)
Local administrator account

If any enabled accounts have not been logged on to within the past 35 days, this is a finding.

Inactive accounts that have been reviewed and deemed to be required must be documented with the ISSO.

#>
