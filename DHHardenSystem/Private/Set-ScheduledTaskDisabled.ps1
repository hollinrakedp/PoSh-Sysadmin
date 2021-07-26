function Set-ScheduledTaskDisabled {
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

    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]

    Param(
        [Parameter()]
        [string[]]$TaskName = @("Adobe Acrobat Update Task", "Consolidator", "OneDrive Standalone Update Task v2", "XblGameSaveTask"),
        [string[]]$TaskPath = @("\Microsoft\Windows\Bluetooth\")
    )

    begin {
        $AllScheduledTasks = Get-ScheduledTask
    }

    process {
        #region Disable Task by Name
        foreach ($Name in $TaskName) {
            If (($AllScheduledTasks.TaskName) -contains $Name) {
                if ($PSCmdlet.ShouldProcess("$Name")) {
                    Get-ScheduledTask -TaskName $Name | Disable-ScheduledTask
                }
            }
        }
        #endregion Disable Task by Name

        #region Disable Task by Path
        Foreach ($Path in $TaskPath) {
            If (($AllScheduledTasks.TaskPath) -contains $Path) {
                if ($PSCmdlet.ShouldProcess("$Path")) {
                    Get-ScheduledTask -TaskPath $Path | Disable-ScheduledTask
                }
            }
        }
        #endregion Disable Task by Path
    }

    end {}
}