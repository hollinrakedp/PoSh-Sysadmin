function Get-InstalledApplication {
    <#
    .SYNOPSIS
    Retrieves a list of installed applications from the Windows registry

    .DESCRIPTION
    This function queries the Windows registry to retrieve information about installed applications.
    It can gather applications installed globally (for all users) or for specific users by examining
    the uninstall registry keys in HKEY_LOCAL_MACHINE and HKEY_USERS hives. The function supports
    various parameter sets to control the scope of the search and includes information about whether
    each application is installed globally or for specific users.

    .NOTES
    Name        : Get-InstalledApplication
    Author      : Darren Hollinrake
    Version     : 1.1
    Date Created: 2022-05-27
    Date Updated: 2025-11-11

    .PARAMETER Global
    Retrieves only applications installed globally (for all users) from HKEY_LOCAL_MACHINE registry.

    .PARAMETER GlobalAndCurrentUser
    Retrieves applications installed globally and for the current user.

    .PARAMETER GlobalAndAllUsers
    Retrieves applications installed globally and for all users on the system. Requires administrator privileges.

    .PARAMETER CurrentUser
    Retrieves only applications installed for the current user from HKEY_CURRENT_USER registry.

    .PARAMETER AllUsers
    Retrieves applications installed for all users on the system by examining all user profiles. Requires administrator privileges.

    .EXAMPLE
    Get-InstalledApplication

    DisplayName                     DisplayVersion    InstallScope    InstallDate
    -----------                     --------------    ------------    -----------
    Visual Studio Community 2022    17.13.7          Global          20250422
    Notepad++                       8.7.5            User            20231205
    Microsoft Edge                  142.0.3595.76    Global          20251111

    Retrieves all installed applications (global and all users) using the default parameter set.

    .EXAMPLE
    Get-InstalledApplication -Global

    DisplayName                     DisplayVersion    InstallScope    InstallDate
    -----------                     --------------    ------------    -----------
    Visual Studio Community 2022    17.13.7          Global          20250422
    Microsoft Edge                  142.0.3595.76    Global          20251111

    Retrieves only applications installed globally for all users.

    .EXAMPLE
    Get-InstalledApplication -CurrentUser

    DisplayName                     DisplayVersion    InstallScope    InstallDate
    -----------                     --------------    ------------    -----------
    Notepad++                       8.7.5            User            20231205
    Steam                           2.10.91.91       User

    Retrieves only applications installed for the current user.

    .EXAMPLE
    Get-InstalledApplication -AllUsers | Where-Object {$_.DisplayName -like "*Office*"}

    DisplayName                     DisplayVersion    InstallScope    InstallDate
    -----------                     --------------    ------------    -----------
    Microsoft Office Professional  16.0.12345.67890 User            20240315

    Retrieves all user-installed applications and filters for those containing "Office" in the name.

    #>
    [CmdletBinding(DefaultParameterSetName = 'GlobalAndAllUsers')]
    param (
        [Parameter(ParameterSetName = "Global")]
        [switch]$Global,
        [Parameter(ParameterSetName = "GlobalAndCurrentUser")]
        [switch]$GlobalAndCurrentUser,
        [Parameter(ParameterSetName = "GlobalAndAllUsers")]
        [switch]$GlobalAndAllUsers,
        [Parameter(ParameterSetName = "CurrentUser")]
        [switch]$CurrentUser,
        [Parameter(ParameterSetName = "AllUsers")]
        [switch]$AllUsers
    )

    if ($PSCmdlet.ParameterSetName -eq "GlobalAndAllUsers") {
        $GlobalAndAllUsers = $true
    }

    if ($GlobalAndAllUsers -or $AllUsers) {
        $IsAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (!($IsAdmin)) {
            Write-Error "You must be an administrator to gather installed applications for all users"
            break
        }
    }

    $Apps = @()
    $32BitPath = "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $64BitPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"

    if ($Global -or $GlobalAndAllUsers -or $GlobalAndCurrentUser) {
        Write-Verbose "Processing Local Machine Registry"
        $GlobalApps = @()
        $GlobalApps += Get-ItemProperty "HKLM:\$32BitPath"
        $GlobalApps += Get-ItemProperty "HKLM:\$64BitPath"
        $GlobalApps | ForEach-Object {
            $_ | Add-Member -NotePropertyName "InstallScope" -NotePropertyValue "Global" -Force
        }
        $Apps += $GlobalApps
    }

    if ($CurrentUser -or $GlobalAndCurrentUser) {
        Write-Verbose "Processing Current User Registry"
        $CurrentUserApps = @()
        $CurrentUserApps += Get-ItemProperty "HKCU:\$32BitPath"
        $CurrentUserApps += Get-ItemProperty "HKCU:\$64BitPath"
        $CurrentUserApps | ForEach-Object {
            $_ | Add-Member -NotePropertyName "InstallScope" -NotePropertyValue "User" -Force
        }
        $Apps += $CurrentUserApps
    }

    if ($AllUsers -or $GlobalAndAllUsers) {
        Write-Verbose "Collecting Registry Hive data for all users"
        $AllProfiles = Get-CimInstance Win32_UserProfile | Select-Object LocalPath, SID, Loaded, Special | Where-Object { $_.SID -like "S-1-5-21-*" }
        $MountedProfiles = $AllProfiles | Where-Object { $_.Loaded -eq $true }
        $UnmountedProfiles = $AllProfiles | Where-Object { $_.Loaded -eq $false }

        Write-Verbose "Processing mounted hives"
        $MountedProfiles | ForEach-Object {
            $UserApps = @()
            $UserApps += Get-ItemProperty -Path "Registry::\HKEY_USERS\$($_.SID)\$32BitPath"
            $UserApps += Get-ItemProperty -Path "Registry::\HKEY_USERS\$($_.SID)\$64BitPath"
            $UserApps | ForEach-Object {
                $_ | Add-Member -NotePropertyName "InstallScope" -NotePropertyValue "User" -Force
            }
            $Apps += $UserApps
        }

        Write-Verbose "Processing unmounted hives"
        $UnmountedProfiles | ForEach-Object {

            $Hive = "$($_.LocalPath)\NTUSER.DAT"
            Write-Verbose "Mounting hive at $Hive"

            if (Test-Path $Hive) {
                REG LOAD HKU\temp $Hive 2>$null | Out-Null

                $UnmountedUserApps = @()
                $UnmountedUserApps += Get-ItemProperty -Path "Registry::\HKEY_USERS\temp\$32BitPath"
                $UnmountedUserApps += Get-ItemProperty -Path "Registry::\HKEY_USERS\temp\$64BitPath"
                $UnmountedUserApps | ForEach-Object {
                    $_ | Add-Member -NotePropertyName "InstallScope" -NotePropertyValue "User" -Force
                }
                $Apps += $UnmountedUserApps

                # Run Garbage Collection
                [GC]::Collect()
                [GC]::WaitForPendingFinalizers()
                REG UNLOAD HKU\temp 2>$null | Out-Null
            }
            else {
                Write-Warning "Unable to access registry hive at $Hive"
            }
        }
    }

    $Apps = $Apps | Where-Object { -not [String]::IsNullOrEmpty($_.DisplayName) }

    $defaultDisplaySet = 'DisplayName', 'DisplayVersion', 'InstallScope', 'InstallDate'
    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    $Apps | Add-Member MemberSet PSStandardMembers $PSStandardMembers

    $Apps
}