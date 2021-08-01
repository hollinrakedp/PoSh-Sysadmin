function Remove-WinApp {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$App = @("Microsoft.BingWeather",
            "Microsoft.GetHelp",
            "Microsoft.Getstarted",
            "Microsoft.Messaging",
            "Microsoft.Microsoft3DViewer",
            "Microsoft.MicrosoftOfficeHub",
            "Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.MixedReality.Portal",
            "Microsoft.Office.OneNote",
            "Microsoft.OneConnect",
            "Microsoft.People",
            "Microsoft.Print3D",
            "Microsoft.SkypeApp",
            "Microsoft.StorePurchaseApp",
            "Microsoft.Wallet",
            "Microsoft.WindowsAlarms",
            "Microsoft.WindowsCamera",
            "microsoft.windowscommunicationsapps",
            "Microsoft.WindowsFeedbackHub",
            "Microsoft.WindowsMaps",
            "Microsoft.WindowsSoundRecorder",
            "Microsoft.Xbox.TCUI",
            "Microsoft.XboxApp",
            "Microsoft.XboxGameOverlay",
            "Microsoft.XboxGamingOverlay",
            "Microsoft.XboxIdentityProvider",
            "Microsoft.XboxSpeechToTextOverlay",
            "Microsoft.YourPhone",
            "Microsoft.ZuneMusic",
            "Microsoft.ZuneVideo")
    )

    ForEach ($AppName in $App) {
        $PackageFullName = (Get-AppxPackage $AppName).PackageFullName
        $ProPackageFullName = (Get-AppxProvisionedPackage -Online | Where-Object { $_.Displayname -eq $AppName }).PackageName
 
        If ($PackageFullName) {
            if ($PSCmdlet.ShouldProcess("$PackageFullName", "Remove-AppxPackage")) {
                Write-Verbose "Removing Package: $AppName"
                Remove-AppxPackage -Package $PackageFullName
            }
        }
 
        Else {
            Write-Host "Unable To Find Package: $AppName"
        }
 
        If ($ProPackageFullName) {
            if ($PSCmdlet.ShouldProcess("$ProPackageFullName", "Remove-AppxProvisionedPackage")) {
                Write-Verbose "Removing Provisioned Package: $ProPackageFullName"
                Remove-AppxProvisionedPackage -Online -PackageName $ProPackageFullName
            }
        }
 
        Else {
            Write-Verbose "Unable To Find Provisioned Package: $AppName"
        }
    }
}