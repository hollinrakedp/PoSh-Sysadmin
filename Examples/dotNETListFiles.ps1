[IO.Directory]::EnumerateFiles("C:\temp", "*", "AllDirectories") | ForEach-Object { Get-Item $_ | Select-Object FullName, Length }