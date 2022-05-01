<#
.SYNOPSIS
Set the number of systems an unprivileged account can join to the domain.

.NOTES
    Name       : Set-MachineAccountQuota
    Author     : Darren Hollinrake
    Version    : 1.0
    DateCreated: 2022-05-01
    DateUpdated: 

#>
param (
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$Identity = (Get-ADDomain.DNSRoot),
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]$Quota = 0
)

Set-ADDomain -Identity "$Identity" -Replace @{"ms-DS-MachineAccountQuota" = "$Quota" }