function Get-InstalledApplication {
    [cmdletbinding(DefaultParameterSetName = 'GlobalAndAllUsers')]

    Param (
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
        $Apps += Get-ItemProperty "HKLM:\$32BitPath"
        $Apps += Get-ItemProperty "HKLM:\$64BitPath"
    }

    if ($CurrentUser -or $GlobalAndCurrentUser) {
        Write-Verbose "Processing Current User Registry"
        $Apps += Get-ItemProperty "HKCU:\$32BitPath"
        $Apps += Get-ItemProperty "HKCU:\$64BitPath"
    }

    if ($AllUsers -or $GlobalAndAllUsers) {
        Write-Verbose "Collecting Registry Hive data for all users"
        $AllProfiles = Get-CimInstance Win32_UserProfile | Select-Object LocalPath, SID, Loaded, Special | Where-Object { $_.SID -like "S-1-5-21-*" }
        $MountedProfiles = $AllProfiles | Where-Object { $_.Loaded -eq $true }
        $UnmountedProfiles = $AllProfiles | Where-Object { $_.Loaded -eq $false }

        Write-Verbose "Processing mounted hives"
        $MountedProfiles | ForEach-Object {
            $Apps += Get-ItemProperty -Path "Registry::\HKEY_USERS\$($_.SID)\$32BitPath"
            $Apps += Get-ItemProperty -Path "Registry::\HKEY_USERS\$($_.SID)\$64BitPath"
        }

        Write-Verbose "Processing unmounted hives"
        $UnmountedProfiles | ForEach-Object {

            $Hive = "$($_.LocalPath)\NTUSER.DAT"
            Write-Verbose "Mounting hive at $Hive"

            if (Test-Path $Hive) {
                REG LOAD HKU\temp $Hive

                $Apps += Get-ItemProperty -Path "Registry::\HKEY_USERS\temp\$32BitPath"
                $Apps += Get-ItemProperty -Path "Registry::\HKEY_USERS\temp\$64BitPath"

                # Run Garbage Collection
                [GC]::Collect()
                [GC]::WaitForPendingFinalizers()
                REG UNLOAD HKU\temp
            }
            else {
                Write-Warning "Unable to access registry hive at $Hive"
            }
        }
    }
    $defaultDisplaySet = 'DisplayName', 'DisplayVersion', 'InstallDate'
    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    $Apps | Add-Member MemberSet PSStandardMembers $PSStandardMembers

    $Apps
}