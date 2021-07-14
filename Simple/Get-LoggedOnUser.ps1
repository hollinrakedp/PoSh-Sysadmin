Function Get-LoggedOnUser {
    Param(
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [Alias("Name", "Server")]
        [string[]]$ComputerName = @("localhost")
    )
    $LoggedOnUsers = $(& quser /Server:$ComputerName) -replace '\s{2,}', ',' | ConvertFrom-Csv
    $LoggedOnUsers
}