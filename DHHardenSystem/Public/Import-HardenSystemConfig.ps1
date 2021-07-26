function Import-HardenSystemConfig {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory)]
        [Alias('Path')]
        [string]$FilePath
    )
    if ((Test-Path $FilePath) -and ($FilePath -match '^*\.json')) {
        $HardenSystemConfigObj = Get-Content "$FilePath" | ConvertFrom-Json
        # Output as a hashtable
        #$HardenSystemConfig = @{}
        #$HardenSystemConfigObj.psobject.properties | ForEach-Object { $HardenSystemConfig[$_.Name] = $_.Value }
    }
    else {
        Write-Warning "The specified path is not valid. Please provide a valid config file path to import."
        return
    }
    $HardenSystemConfigObj
}