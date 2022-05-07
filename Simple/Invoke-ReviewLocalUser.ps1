<#
.SYNOPSIS
Show local accounts that haven't logged on in the specified number of days.

.DESCRIPTION
This script will return a list of local accounts with the account name, last logon, and if the account is enabled 
(True/False). Review the list to determine the finding validity for each account reported.

.NOTES   
Name       : Invoke-ReviewLocalUser.ps1
Author     : Darren Hollinrake
Version    : 1.0
DateCreated: 2018-07-28
DateUpdated: 

#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$Path = "C:\Audit\Archive",
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]$Days = 60
)

begin {}

process {
    $accounts = @()
    $builtinaccts = @()
    $item = New-Object psobject
    $archivepath = "C:\Audit\Archive"
    $path = Join-Path -Path $archivepath -ChildPath $(Get-Date -Format yyyyMMdd)
    $fullpath = Join-Path -Path "$path" -ChildPath "$(Get-Date -Format yyyyMMdd)_$($env:COMPUTERNAME)_LocalUsers.txt"
    $outfile = @{"FilePath"  = "$fullpath"
                 "NoClobber" = $true
                 "Append"    = $true
    }

    Write-Output "Gathering Built-in Accounts"
    $builtinadmin = Get-CimInstance win32_useraccount | Where-Object { $_.SID -like "S-1-5-*" -and $_.SID -like "*-500" } | Select-Object @{Name = "Username"; Expression = { $_.Name } }, SID, Disabled
    $builtinadmin | Add-Member -MemberType NoteProperty -Name "Account" -Value "Administrator"
    $builtinguest = Get-CimInstance win32_useraccount | Where-Object { $_.SID -like "S-1-5-*" -and $_.SID -like "*-501" } | Select-Object @{Name = "Username"; Expression = { $_.Name } }, SID, Disabled
    $builtinguest | Add-Member -MemberType NoteProperty -Name "Account" -Value "Guest"
    $builtindfltacct = Get-CimInstance win32_useraccount | Where-Object { $_.SID -like "S-1-5-*" -and $_.SID -like "*-503" } | Select-Object @{Name = "Username"; Expression = { $_.Name } }, SID, Disabled
    $builtindfltacct | Add-Member -MemberType NoteProperty -Name "Account" -Value "DefaultAccount"
    $builtinaccts = @($builtinadmin, $builtinguest, $builtindfltacct)

    Write-Output "Gathering All Local Accounts"
    $localaccounts = ([ADSI]('WinNT://{0}' -f $env:COMPUTERNAME)).Children | Where-Object { $_.SchemaClassName -eq "user" }
    foreach ($_ in $localaccounts) {
        $user = ([ADSI]$_.Path)
        $lastLogin = $user.Properties.LastLogin.Value
        $enabled = ($user.Properties.UserFlags.Value -band 0x2) -ne 0x2
        if ($null -eq $lastLogin) {
            $lastLogin = 'Never'
        }
        $item = [PSCustomObject]@{
            UserName  = $($user.Name).trim("{", "}")
            Enabled   = $enabled
            LastLogon = $lastLogin
        }
        $Accounts += $item
    }
    #endregion Gather Local Accounts

    #region Output File
    if (!(Test-Path "$path")) {
        New-Item -ItemType Directory -Force -Path "$path" | Out-Null
    }
    #endregion Output File

    #region Built-in Accounts
    Write-Output "Built-in Accounts" | Out-File @outfile
    $MyItems = @()
    foreach ($Account in $builtinaccts) {
        $AcctObj = [PSCustomObject]@{
            Account  = $Account.Account
            UserName = $Account.Username
        }
        $AcctObj
        $MyItems += $AcctObj
    }
    Write-Output $MyItems | Out-File @outfile
    #endregion Built-in Accounts

    #region All Local Accounts
    Write-Output "Local Accounts" | Out-File @outfile
    Write-Output $accounts | Select-Object Username, Enabled | Out-File @outfile
    #endregion All Local Accounts

    #region Enabled Accounts
    $enabledaccounts = $accounts | Where-Object { ($_.Enabled -eq "True") }
    Write-Output "Enabled Local Accounts" | Out-File @outfile
    Write-Output $($enabledaccounts | Select-Object Username, LastLogon | Format-Table) | Out-File @outfile
    #endregion Enabled Accounts

    #region Never Logged On
    $neverlogon = $($accounts | Where-Object { ($_.LastLogon -eq "Never") -and ($_.Enabled -eq "True") }).username -join ', '
    if ($neverlogon.Length -eq 0) {
        Write-Output "There are no enabled accounts with a last logon time of 'Never'.`r`n" | Out-File @outfile
    }
    else {
        Write-Output "The following accounts are enabled but have never logged in: $neverlogon `r" | Out-File @outfile
    }
    #endregion Never Logged On

    #region Logged on >$Days Days Ago
    $gtdayslogon = $($accounts | Where-Object { ($_.LastLogon -lt $(Get-Date).AddDays(-$Days)) -and ($_.LastLogon -notlike "Never") -and ($_.Enabled -eq "True") }).username -join ', '
    if ($gtdayslogon.Length -eq 0) {
        Write-Output "All enabled accounts have been logged into within the past $Days days.`r" | Out-File @outfile
    }
    else {
        Write-Output "Please review the following accounts which have not been logged into for >$Days days: $gtdayslogon `r" | Out-File @outfile
    }
    #endregion Logged on >$Days Days Ago
    Write-Output "Saved information to: $fullpath"
    Write-Output "Script completed"
    Start-Sleep 5
}

end {}