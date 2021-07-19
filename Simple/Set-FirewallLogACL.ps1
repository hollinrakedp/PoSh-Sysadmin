function Set-FirewallLogACL {
    param (
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [Alias("Path","LogPath")]
        [string]$Directory = "$env:SystemRoot\System32\LogFiles\Firewall"
    )

    If (!(Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory
    }

    $Acl = Get-Acl $Directory
    $Acl | Format-List
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule('NT Service\MpsSvc', 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($AccessRule)
    $Acl | Set-Acl $Directory
    Get-Acl $Directory | Format-List
}