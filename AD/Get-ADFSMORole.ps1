#Requires -Module ActiveDirectory
function Get-ADFSMORole {
    [CmdletBinding()]
    param()
    $ADDomain = Get-ADDomain | Select-Object InfrastructureMaster, PDCEmulator, RIDMaster
    $ADForest = Get-ADForest | Select-Object DomainNamingMaster, SchemaMaster
    $FSMORoleOwners = @{
        InfrastructureMaster = $ADDomain.InfrastructureMaster
        PDCEmulator          = $ADDomain.PDCEmulator
        RIDMaster            = $ADDomain.RIDMaster
        DomainNamingMaster   = $ADForest.DomainNamingMaster
        SchemaMaster         = $ADForest.SchemaMaster
    }
    $FSMORoleOwners
}