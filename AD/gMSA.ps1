# For additional information on configuring the gMSA, see:
# https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/windows-server-2012-group-managed-service-accounts/ba-p/255910

# This command only needs to be ran once in the Forest
# If you have only one DC
#Add-KDSRootKey –EffectiveTime ((get-date).addhours(-10))
# If you have more than one DC, wait 10hrs for full replication
Add-KDSRootKey –EffectiveImmediately

# Create a security group to hold the computer objects that will be allowed access to the gMSA
# Security Group: SEC_gMSA_Audit
New-ADGroup -Name "SEC_gMSA_Audit" -SamAccountName SEC_gMSA_Audit -GroupCategory Security -GroupScope Global -Path "OU=Groups,OU=Lab,DC=lab,DC=lan" -Description "Members of this group are able to use the service account 'gMSA_Audit'" # -DisplayName "SEC_gMSA-Audit"
# Add computers to the group
Add-ADGroupMember "SEC_gMSA_Audit" -Members "Computer1$, Computer2$"
# Create the gMSA: gMSA_Audit
# Note: The DNS Hostname typically doesn't matter. You need to specify the Kerberos encryption types to use in a STIGed environment or you will get errors with authentication. 
New-ADServiceAccount -Name gMSA_Audit -DNSHostName gMSA_Audit.lab.lan -PrincipalsAllowedToRetrieveManagedPassword SEC_gMSA_Audit -ManagedPasswordIntervalInDays 30 -KerberosEncryptionType AES128,AES256 -Enabled:$true

# Computers added to the security group will need to be rebooted for the group permissions to take
# Run this on a computer that can use the gMSA
# The PC will need RSAT installed so the Active Directory module is available
Install-AdServiceAccount -Identity gMSA_Audit
# This should return 'True'S
Test-AdServiceAccount -Identity gMSA_Audit
# If you are using the gMSA to run scheduled batch jobs/scripts, you will have to grant the gMSA the ability to “Log on as a batch job” on the machine
# Assign the security group under User Rights Assignment