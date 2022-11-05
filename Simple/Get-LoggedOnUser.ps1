Function Get-LoggedOnUser {
    <#
    .SYNOPSIS
    Displays information about user sessions on a system

    .DESCRIPTION
    This is a wrapper function for 'quser' to output the results as a PowerShell object.

    .NOTES
    Name        : Get-LoggedOnUser
    Author      : Darren Hollinrake
    Version     : 1.0
    Date Created: 2921-07-13
    Date Updated: 2022-11-05

    #>
    param(
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [Alias("Name", "Server")]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )
    foreach ($Computer in $ComputerName) {
        $Users = $(& quser /Server:$ComputerName 2>&1)
        if ($Users.GetType().Name -eq "ErrorRecord") {
            $UserObject = [PSCustomObject]@{
                ComputerName = $Computer
                Username     = $null
                SessionName  = $null
                SessionId    = $null
                State        = $null
                IdleTime     = $null
                LogonTime    = $null
            }
        }
        else {
            $Users = $(& quser /Server:$ComputerName) -replace '\s{2,}', ',' | ConvertFrom-Csv
            $Time = Get-Date
            foreach ($User in $Users) {
                if ($User.ID -eq "Disc") {
                    # Disconnected sessions have no session name.
                    $UserHash = [ordered]@{
                        ComputerName = $Computer
                        Username     = $User.USERNAME
                        SessionName  = $null
                        SessionId    = $User.SESSIONNAME
                        State        = $User.ID
                        IdleTime     = $User.STATE.replace('+', '.')
                        LogonTime    = [datetime]$User.'IDLE TIME'
                    }
                }
                else {
                    $UserHash = [ordered]@{
                        ComputerName = $Computer
                        Username     = $User.USERNAME
                        SessionName  = $User.SESSIONNAME
                        SessionId    = $User.ID
                        State        = $User.STATE
                        IdleTime     = $User.'IDLE TIME'.replace('+', '.')
                        LogonTime    = [datetime]$User.'LOGON TIME'
                    }
                }
                $Duration = (New-TimeSpan -Start $UserHash.LogonTime -End $Time).ToString("dd\:hh\:mm")
                $UserHash += @{Duration = $Duration }
                $UserObject = [PSCustomObject]$UserHash
                $UserObject
            }
        }
    }
}