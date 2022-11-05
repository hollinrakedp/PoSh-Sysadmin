# Add default values to $PSBoundParameters
foreach ($Key in $MyInvocation.MyCommand.Parameters.Keys) {
    $Value = Get-Variable $Key -ValueOnly -ErrorAction SilentlyContinue
    if ($Value -and !$PSBoundParameters.ContainsKey($Key)) {
        $PSBoundParameters[$Key] = $Value 
    }
}