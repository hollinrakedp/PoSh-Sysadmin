function Export-GPOWMIFilter {
    <#
    .SYNOPSIS
    Export WMI filters from Group Policy.

    .DESCRIPTION
    Export existing WMI filters from Group Policy to a tab delimited file.

    .NOTES   
    Name       : Export-ADWMIFilter
    Author     : Darren Hollinrake
    Version    : 1.0
    DateCreated: 2022-03-25
    DateUpdated: 

    .PARAMETER Path
    Specifies the path to the file that will be exported. Provide a path including a file name (ending in .csv) or provide a path to a folder and the file name will be automtically generated (WMIFilter-yyyyMMdd.csv).

    .PARAMETER Overwrite
    Specifies to overwrite the file if it already exists.

    .EXAMPLE
    Export-GPOWMIFilter -Path C:\temp\WMIFilter.csv
    Exports all the existing WMI filters into 'C:\temp\WMIFilter.csv'

    #>
    param (
        [Parameter(Mandatory)]
        [System.IO.FileInfo]$Path,
        [Parameter()]
        [switch]$Overwrite
    )

    if ((Test-Path -Path $Path -PathType Container)) {
        Write-Verbose "Only a directory was provided. Using automatic filename."
        $FullPath = Join-Path -Path $Path -ChildPath "WMIFilter-$(Get-Date -Format yyyyMMdd).csv"
    }
    elseif ((Test-Path -Path $Path -IsValid) -and ($Path -match '^*\.csv')) {
        Write-Verbose "A full path was provided."
        $FullPath = $Path
        $ParentPath = Split-Path $FullPath
        if (!(Test-Path "$ParentPath")) {
            Write-Verbose "Creating path: $ParentPath"
            New-Item -Path $ParentPath -Force -ItemType Directory | Out-Null
        }
    }
    else {
        Write-Warning "The provided path is not valid. Please provide a valid path to a file or directory."
        return
    }
    if (Test-Path "$FullPath") {
        if ($Overwrite) {
            Set-Content $FullPath $NULL
        }
        else {
            Write-Warning "The export file already exists. To overwrite the existing file, use the -Overwrite parameter."
            return
        }
    }

    $WMIFilters = @()
    $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    $DomainDistinguishedName = ($Domain.GetDirectoryEntry()).DistinguishedName
    $SearchRoot = [adsi]("LDAP://CN=SOM,CN=WMIPolicy,CN=System,$DomainDistinguishedName")
    $Search = New-Object System.DirectoryServices.DirectorySearcher($SearchRoot)
    $Search.filter = "(objectclass=msWMI-Som)"
    $results = $Search.FindAll()
    
    foreach ($result in $results) {
        try {
            $msWMIParm1 = $result.properties["mswmi-parm1"].item(0)
        }
        catch {
            $msWMIParm1 = ""
        }
        $ExportFilter = [PSCustomObject]@{
            DistinguishedName = $result.properties["distinguishedname"].item(0)
            "msWMI-Name"      = $result.properties["mswmi-name"].item(0)
            "msWMI-Parm1"     = $msWMIParm1
            "msWMI-Parm2"     = $result.properties["mswmi-parm2"].item(0)
            Name              = $result.properties["name"].item(0)
        }
        $WMIFilters += $ExportFilter
    }

    $FilterCount = ($WMIFilters | Measure-Object).count
  
    if ($FilterCount -ne 0) {
        Write-Output "Export Path: $FullPath"
        Write-Output "Exporting $FilterCount WMI Filters"
        foreach ($WMIFilter in $WMIFilters) {
            Write-Output "Exporting WMI Filter: $($WMIFilter."msWMI-Name")"
            $NewContent = "$($WMIFilter."msWMI-Name")`t$($WMIFilter."msWMI-Parm1")`t$($WMIFilter."msWMI-Parm2")"
            Add-Content $NewContent -path $FullPath
        }
    }
    else {
        Write-Output "There are no WMI Filters to export`n"
    }
}