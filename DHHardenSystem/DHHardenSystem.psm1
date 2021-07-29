$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

Foreach($script in @($Public + $Private)) {
    Try
    {
        . $script.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($script.fullname): $_"
    }
}

$LGPOPath = "$PSScriptRoot\LGPO"
$EnvPath = $Env:Path -split ';'
if (!($EnvPath -contains "$LGPOPath")) {
    $Env:Path += ";$LGPOPath"
}

Export-ModuleMember -Function $Public.Basename