function Get-CurrentSecurityPolicySetting {
    [CmdletBinding()]
    param (
        [string]$Policy
    )
    
    begin {
        
    }
    
    process {
        $result = $Script:CurrentSecPolicy["$Policy"]
        if ([string]::IsNullOrEmpty($result)) {
            "Policy not found"
        }
        else {
            $result
        }
    }
    
    end {
        
    }
}