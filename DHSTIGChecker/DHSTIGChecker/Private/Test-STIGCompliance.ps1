function Test-STIG {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Windows10', 'Server2016', 'Server2019')]
        [string]$STIG,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$ID
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        
    }
}