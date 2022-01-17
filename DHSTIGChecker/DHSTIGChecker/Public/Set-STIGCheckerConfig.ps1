function Set-STIGCheckerConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$IsClassified,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LocalAdminAccountName,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$MemberOfAdministrators,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$IsVDI,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$VDINonPersist,
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory)]
        [Alias('Path')]
        [string]$ConfigPath
    )
    
    begin {
        
    }
    
    process {
        $Hashtable = @{}
        switch ($PSBoundParameters.Keys) {
            IsClassified {
                $Hashtable += @{ IsClassified = $IsClassified.IsPresent }
            }
            LocalAdminAccountName {
                $Hashtable += @{ LocalAdminAccountName = $LocalAdminAccountName }
            }
            MemberOfAdministrators {
                $Hashtable += @{ MemberOfAdministrators = $MemberOfAdministrators }
            }
            IsVDI {
                $Hashtable += @{ IsVDI = $IsVDI.IsPresent }
                $Hashtable += @{ VDINonPersist = $VDINonPersist.IsPresent }
            }
        }

        $Config = [PSCustomObject]$Hashtable

        $JSON = $Config | ConvertTo-Json -Depth 4

        if ((Test-Path -Path $ConfigPath -PathType Container)) {
            Write-Verbose "Only a directory was provided. Using automatic filename."
            $FullPath = Join-Path -Path $ConfigPath -ChildPath "STIGEnvironmentConfig-$(Get-Date -Format yyyyMMdd).json"
        }
        elseif ((Test-Path -Path $ConfigPath -IsValid) -and ($ConfigPath -match '^*\.json')) {
            Write-Verbose "A full path was provided."
            $FullPath = $ConfigPath
            $ParentPath = Split-Path $ConfigPath
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
    
    end {
        
    }
}