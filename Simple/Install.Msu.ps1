function Install-Msu {
    <#
    .SYNOPSIS
    Installs all MSU (Microsoft Update) files in the provided path.

    .DESCRIPTION
    This function searches for MSU files in the specified directory and installs them using wusa.exe.
    It performs quiet installations without requiring user interaction and provides detailed feedback
    on installation results. The function requires administrative privileges and validates the provided
    path before processing. It tracks installation success/failure statistics and handles common
    exit codes appropriately.

    Common exit codes:
    - 0: Success
    - 2359302: Already installed
    - 3010: Success, reboot required

    .PARAMETER Path
    Specifies the directory path to search for MSU files. Defaults to current directory (".\").
    The path must exist and be a valid directory. The function validates this requirement
    using a ValidateScript attribute.

    .EXAMPLE
    Install-Msu
    
    Installs all MSU files found in the current directory.

    .EXAMPLE
    Install-Msu -Path "C:\WindowsUpdates"
    
    Installs all MSU files located in the C:\WindowsUpdates directory.

    .EXAMPLE
    Install-Msu -Path ".\Updates" -Verbose
    
    Installs MSU files from the Updates subdirectory with verbose output enabled.

    .NOTES
    Name        : Install-MSU
    Author      : Darren Hollinrake
    Version     : 1.0
    Date Created: 2025-11-05
    Date Updated:
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({
            if (-not (Test-Path $_ -PathType Container)) {
                throw "Path '$_' does not exist or is not a directory."
            }
            return $true
        })]
        [string]$Path = ".\"
    )
    
    # Administrator Check
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Installation requires administrative privileges. Rerun with elevated rights."
    }
    
    Write-Verbose "Searching for MSU files in: $Path"
    $Updates = Get-ChildItem -Path $Path -Filter "*.msu"
    
    if ($Updates.Count -eq 0) {
        Write-Warning "No MSU files found in the provided path."
        return
    }
    
    Write-Host "Found $($Updates.Count) MSU file(s) to install."
    
    # Results tracking
    $Results = @()
    $SuccessCount = 0
    $FailureCount = 0
    
    foreach ($Update in $Updates) {
        $UpdateFilePath = $Update.FullName
        Write-Host "Installing Update: $($Update.Name)" -ForegroundColor Cyan
        
        $ArgList = @(
            "`"$UpdateFilePath`"",
            "/quiet",
            "/norestart")
        
        try {
            $Process = Start-Process -FilePath "wusa.exe" -ArgumentList $ArgList -Wait -NoNewWindow -PassThru
            
            $Result = [PSCustomObject]@{
                FileName = $Update.Name
                FilePath = $UpdateFilePath
                ExitCode = $Process.ExitCode
                Status = if ($Process.ExitCode -eq 0) { "Success" } 
                        elseif ($Process.ExitCode -eq 2359302) { "Already Installed" }
                        elseif ($Process.ExitCode -eq 3010) { "Success - Reboot Required" }
                        else { "Failed" }
                Timestamp = Get-Date
            }
            
            $Results += $Result
            
            # Update counters and display status
            if ($Process.ExitCode -in @(0, 2359302, 3010)) {
                $SuccessCount++
                Write-Host "  ✓ $($Result.Status)" -ForegroundColor Green
            } else {
                $FailureCount++
                Write-Host "  ✗ (Exit Code: $($Process.ExitCode))" -ForegroundColor Red
            }
        }
        catch {
            $FailureCount++
            $Result = [PSCustomObject]@{
                FileName = $Update.Name
                FilePath = $UpdateFilePath
                ExitCode = $null
                Status = "Error: $($_.Exception.Message)"
                Timestamp = Get-Date
            }
            $Results += $Result
            Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Summary
    Write-Host "`nInstallation Summary:" -ForegroundColor Yellow
    Write-Host "  Successful: $SuccessCount" -ForegroundColor Green
    Write-Host "  Failed: $FailureCount" -ForegroundColor Red
    
    $Results
}