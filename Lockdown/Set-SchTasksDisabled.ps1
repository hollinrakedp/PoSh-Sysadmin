<#
.SYNOPSIS
Disables a list of scheudled tasks.

.NOTES
Name        : Set-SchTasksDisabled.ps1
Author      : Darren Hollinrake
Version     : 1.0
DateCreated : 2018-08-02
DateUpdated : 

.DESCRIPTION
This script will disabled unnecessary scheduled tasks on the system it's ran. You can specify a list of task names, list of 
task paths, or both.

.PARAMETER TaskName
Name of the task to be disabled.

.PARAMETER TaskPath
Path to a scheduled tasks folder. All tasks in the specified path will be disabled.

.EXAMPLE
Set-SchTasksDisabled.ps1
Uses the default list of tasks to be disabled.

#>

[CmdletBinding()]

Param(
    [Parameter()]
    [string[]]$TaskName = @("Adobe Acrobat Update Task", "Consolidator", "OneDrive Standalone Update Task v2", "XblGameSaveTask"),
    [string[]]$TaskPath = @("\Microsoft\Windows\Bluetooth\")
    )

#region Disable Tasks by Name
foreach ($_ in $TaskName) {
    $task = Get-ScheduledTask | where "TaskName" -Like $_
    If ($task) {
        Write-Output "Found task: $($task.TaskName)"
        If ($task.State -ne "Disabled") {
            Write-Output "Disabling now..."
            Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Verbose
        } else {
            Write-Output "The task is already set to disabled."
        }
    } else {
        Write-Warning "No task found matching: $_"
    }
}
#endregion Disable Tasks by Name

#region Disable Tasks by Path
foreach ($_ in $TaskPath) {
    $path = Get-ScheduledTask | where "TaskPath" -Like $_
    If ($path) {
        Write-Output "Found path: $($path.TaskPath)"
        $path | Disable-ScheduledTask -Verbose
    } else {
        Write-Output "No path found matching: $_"
    }
}
#endregion Disable Tasks by Path