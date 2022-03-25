function Import-GPOWMIFilter {
    <#
    .SYNOPSIS
    Import WMI filters into Group Policy.

    .DESCRIPTION
    Import WMI filters from a tab delimited file into Group Policy

    .NOTES   
    Name       : Import-ADWMIFilter
    Author     : Darren Hollinrake
    Version    : 1.0
    DateCreated: 2022-03-25
    DateUpdated: 

    .PARAMETER Path
    Specifies the path to the file that will be imported.

    .EXAMPLE
    Import-GPOWMIFilter -Path C:\temp\WMIFilter.csv
    

    #>
    param (
        [Parameter(Mandatory)]
        [System.IO.FileInfo]$Path
    )
    if (!(Test-Path $Path)) {
        Write-Warning "Unable import WMI Filters. The file `"$Path`" does not exist."
        return
    }
    
    $Header = "Name", "Description", "Filter"
    $WMIFilters = Import-Csv $Path -Delimiter "`t" -Header $Header
    $FilterCount = ($WMIFilters | Measure-Object).count
    
    if ($FilterCount -gt 0) {
        Write-Output "Importing $FilterCount WMI Filters"
        $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
        $DomainDistinguishedName = ($Domain.GetDirectoryEntry()).DistinguishedName
        $msWMIAuthor = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

        foreach ($WMIFilter in $WMIFilters) {
            $WMIGUID = [string]"{$([System.Guid]::NewGuid())}"
            $WMIDN = "CN=$WMIGUID,CN=SOM,CN=WMIPolicy,CN=System,$DomainDistinguishedName"
            $WMIdistinguishedname = $WMIDN
            $WMIID = $WMIGUID
            $msWMICreationDate = Get-Date -Format "yyyyMMddHHmmss.fff000-000"
            $msWMIName = $WMIFilter.Name
    
            $array = @()
            $SearchRoot = [adsi]("LDAP://CN=SOM,CN=WMIPolicy,CN=System,$DomainDistinguishedName")
            $search = new-object System.DirectoryServices.DirectorySearcher($SearchRoot)
            $search.filter = "(objectclass=msWMI-Som)"
            $results = $search.FindAll()
            ForEach ($result in $results) {
                $array += $result.properties["mswmi-name"].item(0)
            }
    
            if ($array -notcontains $msWMIName) {
                Write-Output "Importing WMI Filter: $msWMIName"
                $SOMContainer = [adsi]("LDAP://CN=SOM,CN=WMIPolicy,CN=System,$DomainDistinguishedName")
                $NewWMIFilter = $SOMContainer.create('msWMI-Som', "CN=$WMIGUID")
                $NewWMIFilter.put("msWMI-Name", $msWMIName)
                $NewWMIFilter.put("msWMI-Parm1", "$($WMIFilter.Description) ")
                $NewWMIFilter.put("msWMI-Parm2", $WMIFilter.Filter)
                $NewWMIFilter.put("msWMI-Author", $msWMIAuthor)
                $NewWMIFilter.put("msWMI-ID", $WMIID)
                $NewWMIFilter.put("instanceType", 4)
                $NewWMIFilter.put("showInAdvancedViewOnly", "TRUE")
                $NewWMIFilter.put("distinguishedname", $WMIdistinguishedname)
                $NewWMIFilter.put("msWMI-ChangeDate", $msWMICreationDate)
                $NewWMIFilter.put("msWMI-CreationDate", $msWMICreationDate)
                $NewWMIFilter.setinfo()
            }
            else {
                Write-Warning "WMI Filter `"$msWMIName`" already exists. Skipping"
            }
        }
    }
    else {
        Write-Warning "The data in the $Path file is missing."
    }
}