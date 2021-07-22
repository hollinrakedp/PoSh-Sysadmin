function Import-LocalSTIGGPO {
    <#
    .SYNOPSIS
    Import DISA STIG GPOs to be applied against the local system.

    .DESCRIPTION
    Quickly applies DISA STIG GPOs against he local system. This script requires the Microsoft LGPO tool on the system and the DISA GPO Package. It is also possible to import any other GPO backup as well.

                
    .NOTES
    Name         - Import-LocalSTIGGPO
    Version      - 0.1
    Author       - Darren Hollinrake
    Date Created - 2020-05-25
    Date Updated - 

    Requirements
    --------------
    DoD GPO Package: Extract the contents of DISA STIG GPO Package zip file (I.E. 'C:\LocalGPO\GPO').
    LGPO Utility: Download and place in a 'PATH' location or in the 'C:\LocalGPO\LGPO' folder.
    
    
    From an elevated PowerShell terminal, dot source this script to make the 'Import-LocalSTIGGPO' function available. For example, if the script is in 'C:\LocalGPO', change to that directory and run ". .\Import-LocalSTIGGPO.ps1". Navigate to the root directory of the previously extracted files (C:\LocalGPO\GPO). You can select any of the GPO's to run by using the folder name without the version/release portion as the -STIG parameter and the version/release portion as the -Version parameter. See the examples for additional details.

    Downloads
    -------------
    DISA GPO Package: https://public.cyber.mil/stigs/gpo/
    LGPO Utility: https://www.microsoft.com/en-us/download/details.aspx?id=55319

    .PARAMETER STIG
    Name of the STIG you are importing. If you are using the STIG GPO package, this should match the folder name excluding the version/release. For example, the folder is 'DoD Google Chrome V1R18', you would use 'DoD Google Chrome' for the STIG parameter. Use this if the DISA GPO Package was extracted and folder structure kept intact. Otherwise, use the -GPOPath parameter

    .PARAMETER Version
    Version of the STIG you are importing. If you are using the STIG GPO package, this should match the folder name excluding the STIG name. For example, the folder is 'DoD Google Chrome V1R18', you would use 'V1R18' for the version parameter. Use this if the DISA GPO Package was extracted and folder structure kept intact. Otherwise, use the -GPOPath parameter

    .PARAMETER GPOPath
    Specify a path to the root folder containing the GUID folder (i.e. {41463F69-E6EE-47A2-B468-CDAE125A2055}). Any GUID folders within the specified location will be imported. This can be used to load a set of GPO's all saved to a single folder.

    .PARAMETER LGPO
    Directory containing the 'lgpo.exe' file. If your 'PATH' variable includes the 'lgpo.exe' location, you do not need to set this parameter.

    .EXAMPLE
    Import-LocalSTIGGPO -STIG "DoD Google Chrome" -Version "V1R16"
        Confirm
        Are you sure you want to perform this action?
        Performing the operation "Import STIG GPO" on target "DoD Google Chrome v1r16".
        [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
        LGPO.exe v2.2 - Local Group Policy Object utility

        Appy security template: .\GPO\DoD Google Chrome v1r16\GPOs\{41463F69-E6EE-47A2-B468-CDAE125A2055}\DomainSysvol\GPO\Machine\Microsoft\Windows NT\SecEd9t\GptTmpl.inf
        Import Machine settings from registry.pol: .\GPO\DoD Google Chrome v1r16\GPOs\{41463F69-E6EE-47A2-B468-CDAE125A2055}\DomainSysvol\GPO\Machine\registry.pol
    
    -----------------------------------------------
    Imports the DISA Google Chrome GPO. A prompt will appear to confirm before the actual import. The DISA GPOs were extracted to a folder called 'GPO' with their file structure left intact.

    .EXAMPLE
    Import-LocalSTIGGPO -STIG "DoD Google Chrome" -Version "V1R16" -Confirm:$False
        LGPO.exe v2.2 - Local Group Policy Object utility

        Appy security template: .\GPO\DoD Google Chrome v1r16\GPOs\{41463F69-E6EE-47A2-B468-CDAE125A2055}\DomainSysvol\GPO\Machine\Microsoft\Windows NT\SecEd9t\GptTmpl.inf
        Import Machine settings from registry.pol: .\GPO\DoD Google Chrome v1r16\GPOs\{41463F69-E6EE-47A2-B468-CDAE125A2055}\DomainSysvol\GPO\Machine\registry.pol
    
    -----------------------------------------------
    Imports the DISA Google Chrome GPO. There will be no confirm prompt. The DISA GPOs were extracted to a folder called 'GPO' with their file structure left intact.

    .EXAMPLE
    Import-LocalSTIGGPO -STIG "DoD Google Chrome" -Version "V1R16" -WhatIf
        What if: Performing the operation "Import STIG GPO" on target "DoD Google Chrome v1r16".
    
    .EXAMPLE
    Import-CSV .\STIGList.csv | Import-LocalSTIGGPO -Confirm:$False
    LGPO.exe v2.2 - Local Group Policy Object utility

        Appy security template: .\GPO\DoD Google Chrome v1r16\GPOs\{41463F69-E6EE-47A2-B468-CDAE125A2055}\DomainSysvol\GPO\Machine\Microsoft\Windows NT\SecEd9t\GptTmpl.inf
        Import Machine settings from registry.pol: .\GPO\DoD Google Chrome v1r16\GPOs\{41463F69-E6EE-47A2-B468-CDAE125A2055}\DomainSysvol\GPO\Machine\registry.pol

        Appy security template: .\GPO\DoD Windows 10 v1r18\GPOs\{71763F69-EEAD-4121-A868-EB49F6E62012}\DomainSysvol\GPO\Machine\Microsoft\Windows NT\SecEd9t\GptTmpl.inf
        Import Machine settings from registry.pol: .\GPO\DoD Google Chrome v1r16\GPOs\{71763F69-EEAD-4121-A868-EB49F6E62012}\DomainSysvol\GPO\Machine\registry.pol
    
    -----------------------------------------------
    Imports any GPOs listed in the CSV file.
    
    CSV Contents:
    STIG, Version
    DoD Google Chrome, v1r16
    DoD Windows 10, v1r18

    #>

    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='High')]
    param (
        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName = 'STIG')]
        [ValidateNotNullOrEmpty()]
        [Alias("Name")]
        [String]$STIG,
        [Parameter(ValueFromPipelineByPropertyName,
        ParameterSetName = 'STIG')]
        [ValidateNotNullOrEmpty()]
        [Alias("STIGVersion")]
        [String]$Version,
        [Parameter(ValueFromPipelineByPropertyName,
        ParameterSetName = 'Custom')]
        [Alias("Path")]
        $GPOPath,
        [Parameter(ValueFromPipelineByPropertyName)]
        $LGPO

    )
    
    begin {
        if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
            Write-Warning "This script requires elevated privileges to run. Start Windows PowerShell by  using the Run as Administrator option, and then try running the script again."
            exit 1
        }

        try {
            Write-Verbose "Verifying LGPO is available on the system."
            if (Get-Command "lgpo.exe" -ErrorAction Stop){
                Write-Verbose "Found 'lgpo.exe' in 'PATH'."
                $LGPOPath = "lgpo.exe"
            }
        }

        catch [System.Management.Automation.CommandNotFoundException] {
            Write-Debug "Unable to find 'lgpo.exe' in 'PATH'."
            try {
                if (Get-Command "$LGPO\lgpo.exe" -ErrorAction Stop){
                Write-Verbose "Found 'lgpo.exe' in the 'LGPO' folder."
                $LGPOPath = "$LGPO\lgpo.exe"
                }
            }

            catch [System.Management.Automation.CommandNotFoundException] {
                Write-Debug "Unable to find 'lgpo.exe' in the 'LGPO' folder."
                Write-Warning "The LGPO executable has not been found. Exiting..."
                exit 1
            }
        }
        
    }
    
    process {
        if ($pscmdlet.ShouldProcess("$STIG $Version", "Import STIG GPO")) {
            if([string]::IsNullOrEmpty($GPOPath)){
                $GPOPath = ".\$STIG" + " $Version\GPOs"
            }
            & "$LGPOPath" /g "$GPOPath"

        }
    }
    
    end {
        
    }
}