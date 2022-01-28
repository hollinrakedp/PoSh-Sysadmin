$Credential = Get-Credential
$PSDrive = @{
    Name = "PSDrive"
    PSProvider = "FileSystem"
    Root = "\\filer\share"
    Credential = $Credential
}

Invoke-Command -ComputerName $computerName -ScriptBlock {
    New-PSDrive @using:PSDrive
    Start-Process "\\filer\share\installer.exe" -ArgumentList "/silent" -Wait -NoNewWindow
} 