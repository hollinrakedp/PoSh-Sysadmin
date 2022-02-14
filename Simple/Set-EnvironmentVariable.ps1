function Set-EnvironmentVariable {
    param
    (
        [Parameter(Mandatory)]
        [String]$Name,
        [Parameter(Mandatory)]
        [String]$Value,
        [Parameter(Mandatory)]
        [ValidateSet("User", "Machine")]
        [EnvironmentVariableTarget]$Target
    )
    [System.Environment]::SetEnvironmentVariable($Name, $Value, $Target)
}