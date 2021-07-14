function Write-LogEntry {
    <#
    .Synopsis
    Write-LogEntry writes a message to a specified log file with the current time stamp. 
    
    .DESCRIPTION
    The Write-LogEntry function adds logging capability to other scripts. In addition to writing the entries to a log file, it can output all messages to the console with the "-Verbose" parameter. Any messages with a level set to 'WARN' or 'ERROR' are output to the console.
    
    .NOTES
    Name       : Write-LogEntry
    Author     : Darren Hollinrake
    Version    : 0.2
    DateCreated: 2019-01-04
    DateUpdated: 2019-08-21

    2021-07-13
    Code refactoring

    2019-08-21
    Updated help documentation for additional clarification.

    .PARAMETER Message
    This contains the message to be added to the log file. It should not include a timestamp or log level.
    
    .PARAMETER Path
    The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.
    
    .PARAMETER File
    The name of the log file to be used.

    .PARAMETER Level
    Specify the level of the log message being written to the log (ERROR, WARN, INFO)
    
    .PARAMETER StartLog
    Writes a 3-line entry to the log to clearly indicate the start of a script.
    
    .PARAMETER StartLog
    Writes a 3-line entry to the log to clearly indicate the end of a script.

    .EXAMPLE
    Write-LogEntry -Message 'Log message'
    Writes the message 'Log Message' to: C:\temp\Logs\PowerShell-yyyyMMdd.log
    
    .EXAMPLE
    Write-LogEntry -Message 'Restarting Server.' -Path C:\Logs\Scriptoutput.log
    Writes the content to the specified log file and creates the path and file specified.
    
    .EXAMPLE
    Write-LogEntry -Message 'Folder does not exist.' -Path C:\Logs\ -Level Error
    Writes the message as an error message to the specified log path with a filename of 'Powershell-yyyyMMdd.log', and writes the message to the error pipeline.

    .EXAMPLE
    Write-LogEntry -StartLog
    Writes a log start header to the default log located at: C:\temp\Logs\PowerShell-yyyyMMdd.log
    The header message:
        ********************************************************************************
        2021-07-13 19:45:56:965 INFO: Begin "My-FunctionName"
        ********************************************************************************
    Where "My-FunctionName" displays the name of the calling script or function


    #>
    [CmdletBinding(
        SupportsShouldProcess = $True,
        DefaultParameterSetName = 'LogMessage')]
    param(
        [Parameter(
            ParameterSetName = 'LogMessage',
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent,LogMessage")]
        [string]$Message,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('LogPath')]
        [string]$Path = "C:\temp\Logs",

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('LogFile')]
        [string]$File = "PowerShell-$(Get-Date -Format yyyyMMdd).log",

        [Parameter(ParameterSetName = 'LogMessage')]
        [ValidateSet("ERROR", "WARN", "INFO")]
        [Alias('LogLevel')]
        [string]$Level = "INFO",

        [Parameter(ParameterSetName = 'StartLog')]
        [Alias('Start','Begin','BeginLog')]
        [switch]$StartLog,

        [Parameter(ParameterSetName = 'StopLog')]
        [Alias('Stop','End','EndLog')]
        [switch]$StopLog
    )

    Begin {
        $LogFullPath = Join-Path -Path $Path -ChildPath $File
        $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss:fff"
        #region StartLogMessage
        #https://powershell.org/forums/topic/get-parent-function-name/
        
        $CallingName = $(Get-PSCallStack)[1].FunctionName
        If ($CallingName -like "<ScriptBlock>*") {
            $CallingName = $(Get-PSCallStack)[1].Command
        }
        #endregion StartLog
    }

    Process {
        switch ($($PSCmdlet.ParameterSetName)) {
            'LogMessage' {
                Write-Verbose "Log Error Level: $($Level.ToUpper())"
            
                $LogEntry = "$TimeStamp $($Level.ToUpper())`: $Message"
                # Write message to the proper pipeline
                switch ($Level) {
                    'Error' { Write-Error $Message }
                    'Warn' { Write-Warning $Message }
                    'Info' { Write-Verbose $Message }
                }
                $LogEntry | Add-Content -Path $LogFullPath
            }
            'StartLog' {
                $StartLogMessage = @(
                    "********************************************************************************"
                    "$Timestamp INFO: Begin `"$CallingName`""
                    "********************************************************************************"
                )
                if (!(Test-Path $LogFullPath)) {
                    Write-Verbose "Creating Log File: $LogFullPath"
                    New-Item -Path $LogFullPath -Force -ItemType File
                }
                elseif (Test-Path $LogFullPath) {
                    Write-Verbose "Log File Exists: $LogFullPath"
                }
                Write-Verbose "$StartLogMessage"
                Add-Content -Path $LogFullPath -Value $StartLogMessage
            }
            'StopLog' {
                $StopLogMessage = @(
                    "********************************************************************************"
                    "$Timestamp INFO: END `"$CallingName`""
                    "********************************************************************************"
                )
                Write-Verbose "$StopLogMessage"
                Add-Content -Path $LogFullPath -Value $StopLogMessage
            }
        }
    }

    End {
    }
}