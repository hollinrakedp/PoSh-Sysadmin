$manifest = @{
    Path              = '.\Write-LogEntry\Write-LogEntry.psd1'
    RootModule        = 'Write-LogEntry.psm1' 
    Author            = 'Darren Hollinrake'
    Company           = 'Darren Hollinrake'
    Description       = 'Basic PowerShell Logging functions'
    ModuleVersion     = '1.0'
    FunctionsToExport = @('Write-LogEntry')
}
New-ModuleManifest @manifest