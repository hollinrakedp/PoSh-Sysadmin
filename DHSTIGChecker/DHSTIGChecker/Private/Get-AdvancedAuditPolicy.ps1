function Get-AdvancedAuditPolicy {
    param ()
    auditpol /get /category:* /r | ConvertFrom-Csv
}