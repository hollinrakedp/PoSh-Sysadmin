<#
Add a new task: Add->General->Run PowerShell Script
Type: PowerShell Script
Name: Remove Built-In Apps
PowerShell script: %SCRIPTROOT%\General\Removal\Remove-BuiltInApps.ps1
#>
## List of Apps to Remove
$AppsList = "Microsoft.BingWeather",
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
            "Microsoft.ZuneVideo"

##Remove the Apps listed and deprovision them above or report if app not present
ForEach ($App in $AppsList) {
    $PackageFullName = (Get-AppxPackage $App).PackageFullName
    $ProPackageFullName = (Get-AppxProvisionedPackage -Online | Where {$_.Displayname -eq $App}).PackageName
 
    If ($PackageFullName) {
        Write-Verbose "Removing Package: $App"
        Remove-AppxPackage -Package $PackageFullName
    }
 
    Else {
        Write-Host "Unable To Find Package: $App"
    }
 
    If ($ProPackageFullName) {
        Write-Verbose "Removing Provisioned Package: $ProPackageFullName"
        Remove-AppxProvisionedPackage -Online -PackageName $ProPackageFullName
    }
 
    Else {
        Write-Verbose "Unable To Find Provisioned Package: $App"
    }
}