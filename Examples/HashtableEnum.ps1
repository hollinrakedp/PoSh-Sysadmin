$RootPath = "C:\temp"
$JoinRootPath = @("ResultsFolder", "ArchiveFolder", "EventLogFolder", "LogFolder", "ConfigFolder")
foreach ($_ in $JoinRootPath) {
    $PathHashtable += @{"$($_ -replace "Folder")" = "$(Join-Path -Path $RootPath -ChildPath $_)" }
}
