The purpose of this script is to quickly apply audit configuration settings to a given list of files/folders.

One thing to note, this script, as currently written, will overwrite any existing audit settings for any of the folders 
contained in the SRO list. It WILL NOT change any file/folder permissions. Also, ensure 'Audit File System' is configured 
under 'Object Access' in the advanced audit policy configuration. If this is not enabled, you will not see any audit events 
related to the audit rules applied by the script. I've included the commands (See: Using the Script) to verify the current 
configuration and to set the auditing to enabled.

Variables are used throughout the script. If needed, modify the values to suit your environment before running. The default 
values are relatively sane. More details on the variables and how to set them are included within the script.


Using the Script
=====================
� Copy the files to the local machine. You'll need the following two files in the same folder.
	o Set-SRO_Auditing.ps1
	o SRO_List.txt
� Open an elevated PowerShell terminal.
� Run the script. Two methods are shown below.
	o Change to the directory where the script is located and run the script
	    cd C:\Custom\Lockdown\Auditing
	    .\Set-SRO_Auditing.ps1
	o Type the full path to the script
	    C:\Custom\Lockdown\Auditing\Set-SRO_Auditing.ps1
� The script should complete within a couple seconds and should indicate the location of the log.
	o If you have a bunch of red errors appearing, ensure you have administrative rights and the SRO list file is in the 
	  same directory.
	o Default log location: C:\temp
� Enable auditing of the File System if not already enabled.
	o View the current setting
	    Auditpol /get /subcategory:"File System"
	    If it returns a value of "No Auditing", no events will be generated
	o Set auditing of the File System
	    Auditpol /set /subcategory:"File System" /success:enable /failure:enable
	    This should match the success/failure setting configured in the the script variable $AuditType.


All testing was done on a Win10v1709 installation but should function fine on any version of Win10. It should work with any 
version of Windows with PowerShell v3 or higher, you'll just need to swap out the SRO list with one appropriate to the OS.
