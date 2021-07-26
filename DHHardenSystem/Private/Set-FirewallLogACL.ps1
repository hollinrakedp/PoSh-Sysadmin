function Set-FirewallLogACL {
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
    param (
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [string]$Path = "$env:SystemRoot\System32\LogFiles\Firewall"
    )

    begin {
        If (!(Test-Path $Path)) {
            Write-Error "The specified Path does not exist." -ErrorAction Stop
        }
    }
    
    process {
        if ($PSCmdlet.ShouldProcess("$Path")) {
            $Acl = Get-Acl $Path
            $Acl | Format-List
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule('NT Service\MpsSvc', 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
            $Acl.SetAccessRule($AccessRule)
            $Acl | Set-Acl $Path
        }
    }

    end {}

}