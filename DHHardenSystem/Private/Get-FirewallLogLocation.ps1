function Get-FirewallLogLocation {
    param (
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [ValidateSet('All','Domain','Private','Public')]
        [Alias('ProfileName')]
        [string]$Name = 'All'
    )

    $Params = switch ($Name) {
        All { @{All = $true} }
        Default { @{Name = $Name} }
    }
    $FWProfiles = Get-NetFirewallProfile @Params
    $FirewallLog = @()
    foreach ($FWProfile in $FWProfiles) {
        $FirewallLogObj = [PSCustomObject]@{
            Name        = $FWProfile.Name
            LogFile     = $FWProfile.LogFileName
        }
        $FirewallLog += $FirewallLogObj
    }
    $FirewallLog
}