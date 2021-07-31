function Export-HardenSystemConfig {
    <#
    .SYNOPSIS
    Saves a configuration file that can be used with the function: Invoke-HardenSystem.

    .DESCRIPTION
    This script accepts input for the same parameters as can be used with 'Invoke-HardenSytem'. The inputs are then saved as a JSON configuration file. This configuration can then be imported using 'Import-HardenSystemConfig'.

    Specify the parameters the same as you would for 'Invoke-HardenSystem'. For parameters that are included within the configuration file, see 'Invoke-HardenSystem' for details.


    .NOTES
    Name         - Export-HardenSystemConfig
    Version      - 0.1
    Author       - Darren Hollinrake
    Date Created - 2021-07-24
    Date Updated - 

    .PARAMETER FilePath
    Specify the output location for the generated configuration file. If only a directory is specified, the filename will be automatically generated (HardenSystemConfig-yyyyMMdd.json). If the path specified does not exist, it will be created.

    .EXAMPLE
    $ApplyGPO = @{OS = 'Win10'; Netbanner = 'Test'; Office = '2016'; Defender = $true ;AppLocker = 'Audit'}
    Export-HardenSystemConfig -ApplyGPO $ApplyGPO -Path "C:\Temp\Custom.json"
    Config file saved to: C:\temp\Custom.json

    The first line creates a hash table which is used in the subsequent command and passed as the value for the 'ApplyGPO' parameter. The second line sets all the parameters that are to be included in the output of the configuration file. The configuration file is saved to 'C:\Temp\Custom.json'.
    
    .EXAMPLE
    $ApplyGPO = @{OS = 'Win10'; Netbanner = 'Test'; Office = '2016'; Defender = $true ;AppLocker = 'Audit'}
    $DisableService = 'ALG','AJRouter','BTAGService','bthserv','BthHFserv','DiagTrack','dmwappushservice','Fax','FrameServer','icssvc','lfsvc','lltdsvc','MapsBroker','MSiSCSI','NcbService','PhoneSvc','QWAVE','RetailDemo','RemoteAccess','RMSvc','SharedAccess','SSDPSRV','TapiSrv','WalletService','WFDSConMgrSvc','wlidsvc','WMPNetworkSvc','workfoldersvc','WpcMonSvc','xbgm','XblAuthmanager','XblGameSave','XboxGipSvc','XboxNetApiSvc'
    Export-HardenSystemConfig -ApplyGPO $ApplyGPO -DEP OptOut -DisablePoshV2 -DisableScheduledTask -DisableService $DisableService -EnableLog "Microsoft-Windows-PrintService/Operational", "Microsoft-Windows-TaskScheduler/Operational" -Mitigation RC4,SpeculativeExecution,SSL3Server,TLS1Server,TripleDES -Path .\Default.json
    This command is used to create the 'Default.json' file included with this module.

    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable[]]$ApplyGPO,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('AlwaysOff', 'AlwaysOn', 'OptIn', 'OptOut')]
        [string]$DEP,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DisablePoshV2,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DisableScheduledTask,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$DisableService,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$EnableLog,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Mitigation,
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory)]
        [Alias('Path')]
        [string]$FilePath
    )

    $Config = [PSCustomObject]@{
        ApplyGPO             = $ApplyGPO
        DEP                  = $DEP
        DisablePoshV2        = $DisablePoshV2.IsPresent
        DisableScheduledTask = $DisableScheduledTask.IsPresent
        DisableService       = $DisableService
        EnableLog            = $EnableLog
        Mitigation           = $Mitigation
    }
    $JSON = $Config | ConvertTo-Json

    if ((Test-Path -Path $FilePath -PathType Container)) {
        Write-Verbose "Only a directory was provided. Using automatic filename."
        $FullPath = Join-Path -Path $FilePath -ChildPath "HardenSystemConfig-$(Get-Date -Format yyyyMMdd).json"
    }
    elseif ((Test-Path -Path $FilePath -IsValid) -and ($FilePath -match '^*\.json')) {
        Write-Verbose "A full path was provided."
        $FullPath = $FilePath
        $ParentPath = Split-Path $FilePath
        if (!(Test-Path "$ParentPath")) {
            if ($PSCmdlet.ShouldProcess("$ParentPath", "New-Item")) {
                Write-Verbose "Creating path: $ParentPath"
                New-Item -Path $ParentPath -Force -ItemType Directory | Out-Null
            }
        }
    }
    else {
        Write-Warning "The provided path is not valid. Please provide a valid path to a file or directory."
        return
    }
    if ($PSCmdlet.ShouldProcess("$FullPath", "Out-File")) {
        Write-Output "Config file saved to: $FullPath"
        $JSON | Out-File $FullPath | Out-Null
    }
}