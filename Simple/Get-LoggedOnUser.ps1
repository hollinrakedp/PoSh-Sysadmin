function Get-LoggedOnUser {
    <#
    .SYNOPSIS
    Displays information about user sessions on a system

    .DESCRIPTION
    This is a wrapper function for 'quser' to output the results as a PowerShell object.
    
    .NOTES
    Name        : Get-LoggedOnUser
    Author      : Darren Hollinrake
    Version     : 1.1
    Date Created: 2021-07-13
    Date Updated: 2024-01-22

    .PARAMETER ComputerName
    Specifies the name of the computer or computers for which to retrieve user session information. If not specified, the local computer ($env:COMPUTERNAME) is used.

    .EXAMPLE
    Get-LoggedOnUser
    ComputerName : Workstation1
    Username     : user1
    LogonTime    : 1/12/2024 12:40:00 AM
    State        : Active
    SessionName  : console
    IdleTime     : none
    SessionId    : 1
    Duration     : 10:17:41

    Retrieve user session information for the local computer.

    .EXAMPLE
    Get-LoggedOnUser -ComputerName "Server1", "Server2"
    ComputerName : Server1
    Username     : user1
    LogonTime    : 1/20/2024 1:00:00 AM
    State        : Active
    SessionName  : rdp-tcp#0
    IdleTime     : .
    SessionId    : 1
    Duration     : 02:17:15

    ComputerName : Server2
    Username     : user2
    LogonTime    : 1/20/2024 1:00:00 PM
    State        : Active
    SessionName  : rdp-tcp#0
    IdleTime     : .
    SessionId    : 1
    Duration     : 02:05:15

    Retrieves user session information from the specified servers.

    #>
    param(
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [Alias("Name", "Server")]
        [string[]]$ComputerName = @("$env:COMPUTERNAME")
    )
    foreach ($Computer in $ComputerName) {
        $Users = $(& quser /Server:$ComputerName 2>&1)
        if ($Users.GetType().Name -eq "ErrorRecord") {
            [PSCustomObject]@{
                ComputerName = $Computer
                Username     = $null
                SessionName  = $null
                SessionId    = $null
                State        = $null
                IdleTime     = $null
                LogonTime    = $null
                $Duration    = $null
            }
        }
        else {
            $Users = $Users -replace '\s{2,}', ',' | ConvertFrom-Csv
            $Time = Get-Date
            foreach ($User in $Users) {
                $UserHash = [ordered]@{
                    ComputerName = $Computer
                    Username     = $User.USERNAME
                }

                if ($User.ID -eq "Disc") {
                    # Disconnected sessions have no session name.
                    $UserHash += @{
                        SessionName = $null
                        SessionId   = $User.SESSIONNAME
                        State       = $User.ID
                        IdleTime    = $User.STATE.replace('+', '.')
                        LogonTime   = [datetime]$User.'IDLE TIME'
                    }
                }
                else {
                    $UserHash += @{
                        SessionName = $User.SESSIONNAME
                        SessionId   = $User.ID
                        State       = $User.STATE
                        IdleTime    = $User.'IDLE TIME'.replace('+', '.')
                        LogonTime   = [datetime]$User.'LOGON TIME'
                    }
                }

                $Duration = (New-TimeSpan -Start $UserHash.LogonTime -End $Time).ToString("dd\:hh\:mm")
                $UserHash += @{Duration = $Duration }
                [PSCustomObject]$UserHash
            }
        }
    }
}