<#
.SYNOPSIS
Set the audit portion of the security access control list (SACL) on a list of files/folders specified in a text document.

.DESCRIPTION
This script will set auditing on a list of files/folders considered Security Relevant Objects (SROs). Any existing auditing rules will be replaced with 
the rules defined in the script below. Modify the variables as required to match your requirements.

The variable '$SROs' identifies a list of files and folders against which the auditing rules will be set. The default is to get the list from a file 
called "SRO_List.txt" and located in the same directory as this script. Include one full file/folder path per line.

The variable '$AuditUser' identifies the user (or group) to which the auditing policy should be applied. The default is set to 'Everyone'.

The variable '$AuditProperties' sets which type of property events will be audited. Below is a list of Audit properties that can be set. The first is 
'Full Control' (aka audit everything). The next two show the values using either the Basic or Advanced properties respectively. Each value represents 
a checkbox you would see in the GUI and is separated from the next value by a comma.
Audit properties: Full Control
    DeleteSubdirectoriesAndFiles, Modify, ChangePermissions, TakeOwnership
Audit properties: Basic Permission Options
    Modify, ReadAndExecute, Read, Write
Audit Properties: Advanced Permissions Options
    ExecuteFile, ReadData, ReadAttributes, ReadExtendedAttributes, CreateFiles, AppendData, WriteAttributes, WriteExtendedAttributes, Delete, ReadPermissions, ChangePermissions, TakeOwnership

The variable '$AuditInheritFlags' set the inherit flags on folders. This determines if files and subfolders inherit the auditing policies. The default 
enables inheritance for both files and subfolders.

The variable '$AuditType' sets the audit flags for the type of events to audit (success and/or failure). The default is to audit success and failure.

The variable '$AuditRuleFolder' combines all our audit variables into a rule that can be applied against any SROs that are FOLDERS. **DO NOT MODIFY THIS VARIABLE**

The variable '$AuditRuleFile' combines all our audit variables into a rule that can be applied against any SROs that are FILES. **DO NOT MODIFY THIS VARIABLE**

The variable '$AuditRule' combines all our audit variables into a rule that can be applied against the SROs. DO NOT **MODIFY**
Format for the Audit rule is as follows:
(IdentityReference,FileSystemRights,InheritanceFlags,PropagationFlags,AuditFlags)

A log will be created in the following location: C:\temp\yyyyMMddHHmmss_Set-SRO_Auditing.log

.NOTES   
Name       : Set-SRO_Auditing.ps1
Author     : Darren Hollinrake
Version    : 0.2
DateCreated: 2018-06-20
DateUpdated: 2018-07-21

Untested:
To add to the audit rules instead of overwriting them, edit the following line: $ACL.SetAuditRule($AuditFileRule)
Change it to: $ACL.AddAuditRule($AuditFileRule)

#>

# WARNING: This script will erase any existing audit rules on files/folders targeted.

###############
#  Variables  #
###############
# Set the variables below as required. See the description above for more information.
$SROs = Get-Content "$PSScriptRoot\SRO_List.txt"
$AuditUser = "Everyone"
$AuditProperties = "CreateFiles, AppendData, WriteAttributes, WriteExtendedAttributes, Delete, ChangePermissions, TakeOwnership"
$AuditInheritFlags = "ContainerInherit, ObjectInherit"
$AuditType = "Success, Failure"
##### DO NOT MODIFY BELOW THIS LINE #####
$AuditRuleFolder = New-Object System.Security.AccessControl.FileSystemAuditRule($AuditUser,$AuditProperties,$AuditInheritFlags,"None",$AuditType)
$AuditRuleFile = New-Object System.Security.AccessControl.FileSystemAuditRule($AuditUser,$AuditProperties,"None","None",$AuditType)

# Ensure our temp path exists
If (!( Test-Path "C:\temp\")) {New-Item -ItemType Directory -Force -Path "C:\temp\"}

# Start logging
Start-Transcript "C:\temp\$(Get-Date -f "yyyyMMddHHmmss")_Set-SRO_Auditing.log"

###############################
#  Begin Setting Audit Rules  #
###############################

Write-Output "Setting auditing rules for SROs"

foreach ($SRO in $SROs) {
    If (!(Test-Path "$SRO")) {
        $writeout = "The following SRO does not exist: " + $SRO
        Write-Warning $writeout
        # Move to the next SRO
        continue
        }
    $ACL = Get-Acl $SRO -Audit
    If ((Get-Item "$SRO").PSIsContainer) {
        $AuditRule = $AuditRuleFolder
        }
        Else {
        $AuditRule = $AuditRuleFile
        }
    $ACL.SetAuditRule($AuditRule)
    $writeout = "Setting auditing on: " + $SRO
    Write-Output $writeout
    $ACL | Set-Acl $SRO
    }

Write-Output "Finished setting auditing rules to SROs."
Stop-Transcript