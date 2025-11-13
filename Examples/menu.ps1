function Start-Menu {
    <#
    .SYNOPSIS
    Creates an interactive console menu system based on a JSON configuration file

    .DESCRIPTION
    This function creates a dynamic, interactive menu system for PowerShell console applications.
    It reads menu structure and options from a JSON configuration file and provides a user-friendly
    interface with main menu and sub-menu navigation. The menu system supports nested options,
    custom actions, and configurable visual elements like menu bars.

    .NOTES
    Name        : Start-Menu
    Author      : Darren Hollinrake
    Version     : 1.0
    Date Created: 2025-11-12
    Date Updated:

    .PARAMETER ConfigFilePath
    Specifies the path to the JSON configuration file that defines the menu structure, options, 
    and actions. The file must contain MenuBar, SubMenuBar, and MainMenu properties.

    .EXAMPLE
    Start-Menu -ConfigFilePath "./MenuConfig.json"

    Starts an interactive menu using the configuration defined in MenuConfig.json in the current directory.

    .EXAMPLE
    Start-Menu -ConfigFilePath "C:\Scripts\CustomMenu.json"

    Starts an interactive menu using a custom configuration file located at the specified absolute path.

    .EXAMPLE
    # Example MenuConfig.json structure:
    {
        "MenuBar": "=====================",
        "SubMenuBar": "---------------------",
        "MainMenu": [
            {
                "Option": "System Information",
                "SubMenu": [
                    {
                        "Title": "Get Computer Info",
                        "Action": "Get-ComputerInfo | Select-Object Name, TotalPhysicalMemory"
                    },
                    {
                        "Title": "Get Disk Space", 
                        "Action": "Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, Size, FreeSpace"
                    }
                ]
            },
            {
                "Option": "Exit"
            }
        ]
    }

    Example of a properly formatted JSON configuration file structure for the menu system.

    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigFilePath
    )
    if (-Not (Test-Path -Path $ConfigFilePath)) {
        Write-Host "Configuration file not found: $ConfigFilePath"
        return
    }

    try {
        $MenuConfig = Get-Content -Path $ConfigFilePath | ConvertFrom-Json
    }
    catch {
        Write-Host "Failed to read or parse configuration file: $ConfigFilePath"
        return
    }

    # Add configurable bars
    $Script:MenuBar = $MenuConfig.MenuBar
    $Script:SubMenuBar = $MenuConfig.SubMenuBar

    while (-not $Script:ExitFlag) {
        Show-MainMenu -MenuOptions $MenuConfig.MainMenu
        $Selection = Read-Host "Please enter your choice"

        if ($Selection -eq 'x') {
            Write-Host "Exiting..."
            $Script:ExitFlag = $true
            break
        }

        $Selection = [int]$Selection
        Invoke-Option -Option $Selection -MenuOptions $MenuConfig.MainMenu
        Start-Sleep -Milliseconds 250
    }
    Remove-Variable ExitFlag -Scope Script
}

function Show-MainMenu {
    <#
    .SYNOPSIS
    Displays the main menu interface with available options

    .DESCRIPTION
    Clears the console and displays the main menu with numbered options based on the provided menu configuration.

    .PARAMETER MenuOptions
    Array of menu options to display in the main menu.

    #>
    param (
        [array]$MenuOptions
    )
    Clear-Host
    Write-Host $Script:MenuBar
    Write-Host " Main Menu"
    Write-Host $Script:MenuBar
    for ($i = 0; $i -lt $MenuOptions.Count; $i++) {
        Write-Host "$($i + 1). $($MenuOptions[$i].Option)"
    }
    Write-Host $Script:MenuBar
}

function Show-SubMenu {
    <#
    .SYNOPSIS
    Displays a sub-menu interface with available sub-options

    .DESCRIPTION
    Clears the console and displays a sub-menu with numbered options, including navigation options
    to return to the main menu or exit the application.

    .PARAMETER Title
    The title to display at the top of the sub-menu.

    .PARAMETER SubMenuOptions
    Array of sub-menu options to display.
    #>
    param (
        [string]$Title,
        [array]$SubMenuOptions
    )
    Clear-Host
    Write-Host $Script:SubMenuBar
    Write-Host " $Title"
    Write-Host $Script:SubMenuBar
    for ($i = 0; $i -lt $SubMenuOptions.Count; $i++) {
        Write-Host "$($i + 1). $($SubMenuOptions[$i].Title)"
    }
    Write-Host "$($SubMenuOptions.Count + 1). Back to Main Menu"
    Write-Host "$($SubMenuOptions.Count + 2). Exit"
    Write-Host $Script:SubMenuBar
}

function Invoke-Option {
    <#
    .SYNOPSIS
    Processes the selected main menu option

    .DESCRIPTION
    Validates the selected option and either exits the application or invokes the corresponding sub-menu.

    .PARAMETER Option
    The numeric option selected by the user.

    .PARAMETER MenuOptions
    Array of available menu options for validation.

    #>
    param (
        [int]$Option,
        [array]$MenuOptions
    )

    if ($Option -le 0 -or $Option -gt $MenuOptions.Count) {
        Write-Host "Invalid option. Please try again."
        return
    }

    $SelectedOption = $MenuOptions[$Option - 1]
    if ($SelectedOption.Option -eq "Exit") {
        Write-Host "Exiting..."
        $Script:ExitFlag = $true
        return
    }

    Invoke-SubMenu -Title $SelectedOption.Option -SubMenuOptions $SelectedOption.SubMenu
}

function Invoke-SubMenu {
    <#
    .SYNOPSIS
    Handles sub-menu navigation and action execution

    .DESCRIPTION
    Displays the sub-menu and processes user selections, executing specified actions
    or handling navigation back to the main menu.

    .PARAMETER Title
    The title of the sub-menu.

    .PARAMETER SubMenuOptions
    Array of sub-menu options containing titles and actions.

    #>
    param (
        [string]$Title,
        [array]$SubMenuOptions
    )

    while ($true) {
        Show-SubMenu -Title $Title -SubMenuOptions $SubMenuOptions
        $Selection = Read-Host "Please enter your choice"

        if ($Selection -eq 'x') {
            Write-Host "Exiting..."
            $Script:ExitFlag = $true
            break
        }

        $Selection = [int]$Selection

        if ($Selection -eq $SubMenuOptions.Count + 1) {
            break
        } elseif ($Selection -eq $SubMenuOptions.Count + 2) {
            Write-Host "Exiting..."
            $Script:ExitFlag = $true
            break
        } elseif ($Selection -gt 0 -and $Selection -le $SubMenuOptions.Count) {
            $SelectedSubOption = $SubMenuOptions[$Selection - 1]
            Write-Host "You selected $($SelectedSubOption.Title)"
            Invoke-Expression $SelectedSubOption.Action
            Invoke-Timeout
        } else {
            Write-Host "Invalid option. Please try again."
        }
        Start-Sleep -Milliseconds 250
    }
}

function Invoke-Timeout {
    <#
    .SYNOPSIS
    Provides a timeout mechanism with user input option

    .DESCRIPTION
    Waits for user input or a specified timeout period, whichever comes first.
    Useful for pausing execution while allowing immediate continuation via key press.

    .PARAMETER TimeoutSeconds
    Number of seconds to wait before automatically continuing. Default is 10 seconds.

    .PARAMETER Message
    Custom message to display to the user. Default message includes the timeout duration.

    #>
    param (
        [int]$TimeoutSeconds = 10,
        [string]$Message = "Press any key to continue or wait $TimeoutSeconds seconds..."
    )

    Write-Host $Message
    $startTime = Get-Date

    while ((Get-Date) - $startTime -lt (New-TimeSpan -Seconds $TimeoutSeconds)) {
        # Check if a key has been pressed
        if ([Console]::KeyAvailable) {
            [void][Console]::ReadKey($true)
            Write-Host "Continuing..."
            return
        }
        Start-Sleep -Milliseconds 100
    }

    Write-Host "Timeout reached. Continuing..."
}

# Call the function to start the menu
Start-Menu -ConfigFilePath "./MenuConfig.json"
