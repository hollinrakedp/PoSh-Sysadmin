function Import-GPOBackup {
    <#
    .SYNOPSIS
    Import one or more Group Policy backups files.

    .DESCRIPTION
    Imports all Group Policy backups located within the specified path. If the GPO exists, it will be overwritten. If the GPO does not already exist, it will be created.

    .NOTES   
    Name       : Import-GPOBackup
    Author     : Darren Hollinrake
    Version    : 1.0
    DateCreated: 2022-03-25
    DateUpdated: 

    .PARAMETER Path
    Specifies the path to a directory containing one or more GPO backups. All directories below this directory are searched for GPO backups.

    .PARAMETER MigrationTable
    Specifies the path to a migration file to use on the imported GPOs.

    .EXAMPLE
    Import-GPOBackup -Path "C:\temp\GPOBackup"
    Imports all the GPOs found in specified path if they already exist. Each GPO found will need to be confirmed before the import will be completed.

    .EXAMPLE
    Import-GPOBackup -Path "C:\temp\GPOBackup" -MigrationTable "\\tsclient\D\Tooling\importtable.migtable" -CreateIfNeeded -Confirm:$false
    Imports all GPOs found in the specified path. If the GPO doesn't exist, it will be created. The information in the migration table will be used during the import of all the GPOs. Confirmation won't be required before the import of each GPO.

    #>
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [System.IO.FileInfo]$Path,
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.IO.FileInfo]$MigrationTable,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$CreateIfNeeded
        
    )
    
    begin {}
    
    process {
        Write-Output "Collecting GPOs to import."
        $GPResults = Get-ChildItem -Path "$Path" -Recurse -Include gpreport.xml
        Write-Verbose "Found $($($GPResults | Measure-Object).Count) GPOs for import."

        foreach ($GPResult in $GPResults) {
            $GPOXML = [XML](Get-Content $GPResult)
            $BackupID = (Get-Item $GPResult).Directory.Name
            $BackupID = $BackupID -replace '{', '' -replace '}', ''
            $TargetName = $($GPOXML.GPO.Name)
            $GPOPath = (Get-Item $GPResult).Directory.Parent.Fullname
            $params = @{
                BackupID       = $BackupID
                TargetName     = "$TargetName"
                Path           = "$GPOPath"
                CreateIfNeeded = $CreateIfNeeded
            }
            if ($MigrationTable) {
                if ((Test-Path $MigrationTable -PathType Leaf) -and ($MigrationTable -match '^*\.migtable')) {
                    $params.Add("MigrationTable", "$MigrationTable")
                }
                else {
                    Write-Warning "The Migration Table file does not exist or does not appear to be a migration table."
                    return
                }
            }
            if ($PSCmdlet.ShouldProcess("$TargetName", "Import-GPO")) {
                Import-GPO @params
            }
        }       
    }
    
    end {}
}