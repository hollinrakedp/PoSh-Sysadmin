function Import-GPOBackup {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string]$Path = "C:\Temp\GPOBackup"
    )
    
    begin {}
    
    process {
        $GPResults = Get-ChildItem -Path "$Path" -Recurse -Include gpreport.xml

        foreach ($GPResult in $GPResults) {
            $GPOXML = [XML](Get-Content $GPResult)
            $BackupID = (Get-Item $GPResult).Directory.Name
            $BackupID = $BackupID -replace '{', '' -replace '}', ''
            $TargetName = $($GPOXML.GPO.Name)
            $GPOPath = (Get-Item $GPResult).Directory.Parent.Fullname

            Import-GPO -BackupID $BackupID -TargetName "$TargetName" -Path "$GPOPath" -CreateIfNeeded
        }       
    }
    
    end {}
}