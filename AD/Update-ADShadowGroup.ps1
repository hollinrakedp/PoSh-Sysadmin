<#
.SYNOPSIS
Update the membership of a shadow group

.DESCRIPTION
The script will update the membership of a shadow group to reflect the current users in the specified OU.

.NOTES   
Name       : Update-ShadowGroup.ps1
Author     : Darren Hollinrake
Version    : 1.0
DateCreated: 2021-02-02
DateUpdated: 

.PARAMETER ShadowGroupName
The identity of the Shadow Group. This is the group in which members of an OU will be added. This can be a distinguished name or group name.

.PARAMETER ShadowOU
The OU path to use for membership of the specified Shadow Group. This should be the distinguished name.

.PARAMETER SearchScope
Specifies the scope of an Active Directory search.

A Base query searches only the current path or object.
A OneLevel query searches the immediate children of that path or object.
A Subtree query searches the current path or object and all children of that path or object.

.EXAMPLE
Update-ShadowGroup -ShadowOU "OU=Users,OU=Lab,DC=home,DC=lab,DC=com" -ShadowGroupName "CN=SHD_Test,OU=Groups,OU=Lab,DC=home,DC=lab,DC=com"
This will add users found in the "Users" OU to the security group "SHD_Test". It will default to searching only one level.

#>

[CmdletBinding()]
Param(
    [Parameter(
        ValueFromPipelineByPropertyName,
        Position = 0)]
    [Alias("ShadowGroup")]
    [string[]]$ShadowGroupName = @(),
    [Parameter(
        ValueFromPipelineByPropertyName)]
    [Alias("OU")]
    [string[]]$ShadowOU = @(),
    [Parameter()]
    [ValidateSet("Base", "OneLevel", "Subtree")]
    [string]$SearchScope = "OneLevel",
    [Parameter()]
    [ValidateSet("User", "Computer", "Both")]
    [string]$MemberType
)


Begin {
<#
Testing Only

$ShadowGroupName = "CN=Admin Accounts,OU=Groups,OU=Privileged,OU=Home,DC=home,DC=lab,DC=com"
$ShadowOU = "OU=Admin,OU=Users,OU=Privileged,OU=Home,DC=home,DC=lab,DC=com"

$ShadowGroupName = "CN=Service Accounts,OU=Groups,OU=Privileged,OU=Home,DC=home,DC=lab,DC=com"
$ShadowOU = "OU=Service Accounts,OU=Users,OU=Privileged,OU=Home,DC=home,DC=lab,DC=com"

#>

<#
Add to Scheduled Tasks
powershell.exe -noprofile -Command "&{Import-Csv -LiteralPath "C:\Script\ShadowGroups.csv" -Delimiter ';' | C:\Script\Update-ShadowGroup.ps1}"

 #Add Computers to Group Based on OU Membership
$Group1 = Get-ADComputer -Filter * -SearchBase "OU= Sites,DC=TEST,DC=local" 
foreach ($Member in $Group1){Add-ADGroupMember -Identity "Group1" -members $Member}

#Add Computers to Group Based on Name
$Group2 = Get-ADComputer -filter {Name -like 'SITE*'}
foreach ($Member in $Group2){Add-ADGroupMember -Identity "Group2" -members $Member}

#Add User to Group Based on OU Membership
$Group3 = Get-ADUser -filter * -SearchBase "OU=Sites,DC=TEST,DC=local" 
foreach ($Member in $Group3){Add-ADGroupMember -Identity "Group3" -members $Member}

#Add User to Group Based on Attribute
$Group4 = Get-ADUser -Filter * -Properties Title | where Title -EQ "Math Teacher"
foreach ($Member in $Group4){Add-ADGroupMember -Identity "Group4"} 

#>
$LogFile = "C:\Script\Update-ShadowGroup.log"
Write-Output "$(Get-Date -Format "yyyyMMdd hh:mm:ss")  Begin Update-ShadowGroup" | Out-File -FilePath $LogFile -Append

}

Process {
    ForEach-Object {
        $RemoveIdenties = Get-ADGroupMember -Identity "$ShadowGroupName" | Where-Object { $_.distinguishedName -NotMatch $ShadowOU }
        ForEach($Identity in $RemoveIdenties) {
            Write-LogEntry -Message "Removing $Identity from $ShadowGroupName"
            #Write-Output "$(Get-Date -Format "yyyyMMdd hh:mm:ss")  Removing $Identity from $ShadowGroupName" | Out-File -FilePath $LogFile -Append
            Remove-ADPrincipalGroupMembership -Identity $Identity -MemberOf $ShadowGroupName -Confirm:$false
        }
        if ($MemberType -eq "User" -or "Both") {
            $AddUsers = Get-ADUser -SearchBase "$ShadowOU" -SearchScope $SearchScope -LDAPFilter "(!memberOf=$ShadowGroupName)"
            ForEach($User in $AddUsers) {
                Write-LogEntry -Message "Adding User $Identity to $ShadowGroupName"
                #Write-Output "$(Get-Date -Format "yyyyMMdd hh:mm:ss")  Adding User $Identity to $ShadowGroupName" | Out-File -FilePath $LogFile -Append
                Add-ADPrincipalGroupMembership -Identity $User -MemberOf $ShadowGroupName
            }            
        }
        if ($MemberType -eq "Computer" -or "Both") {
            $AddComputers = Get-ADComputer -SearchBase "$ShadowOU" -SearchScope $SearchScope -LDAPFilter "(!memberOf=$ShadowGroupName)"
            ForEach($Computer in $AddComputers) {
                Write-LogEntry -Message "Adding Computer $Identity to $ShadowGroupName"
                #Write-Output "$(Get-Date -Format "yyyyMMdd hh:mm:ss")  Adding Computer $Identity to $ShadowGroupName" | Out-File -FilePath $LogFile -Append
                Add-ADPrincipalGroupMembership -Identity $Computer -MemberOf $ShadowGroupName
            }            
        }
    }
}

End {
    Write-Output "$(Get-Date -Format "yyyyMMdd hh:mm:ss")  End Update-ShadowGroup" | Out-File -FilePath $LogFile -Append
}