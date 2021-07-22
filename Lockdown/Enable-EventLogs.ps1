<#
.SYNOPSIS
This script will enable the print and task scheduler event logs.

.NOTES
Name        : Enable-EventLogs.ps1
Author      : Darren Hollinrake
Version     : 1.1
DateCreated : 2018-08-15
DateUpdated : 2018-11-19

.DESCRIPTION
This script will enable the Operational event logs for Print Service and Task Scheduler.

#>

Get-WinEvent -ListLog Microsoft-Windows-PrintService/Operational -OutVariable PrinterLog | Select-Object -Property LogName, IsEnabled
If ($PrinterLog.IsEnabled) {
    Write-Output "The log `"$($PrinterLog.LogName)`" is already enabled."
} Else {
    $PrinterLog.set_IsEnabled($true)
    $PrinterLog.SaveChanges()
}

Get-WinEvent -ListLog Microsoft-Windows-TaskScheduler/Operational -OutVariable TaskSchLog | Select-Object -Property LogName, IsEnabled
If ($TaskSchLog.IsEnabled) {
    Write-Output "The log `"$($TaskSchLog.LogName)`" is already enabled."
} Else {
    $TaskSchLog.set_IsEnabled($true)
    $TaskSchLog.SaveChanges()
}
