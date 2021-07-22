@ECHO Off
goto EndComment
:Comment
Name         - Execute-Custom_GPO_RemovableStorage_Admin_RemDrive_RW.bat
Version      - 1.0
Author       - Darren Hollinrake
Date Created - 2018-11-13
Date Updated - 

.SYNOPSIS
Apply the Custom Group Policy for allowing the Administrators group Read/Write access to removable drives.

.NOTES


:EndComment

:Variables
SETLOCAL
set GPO=Custom - User - Removable Storage - Allow Rem Disk RW
set REGPOL={977F576A-5E33-432A-910F-73B58B01925B}\DomainSysvol\GPO\User\registry.pol

:LogStart
FOR /F "TOKENS=2-4 delims=/ " %%a in ('date /t') do (SET date=%%c%%a%%b)
set LOGFILE="%~dp0ApplyLocalGPO.txt"
ECHO %DATE% %TIME% - Info: Executing script %~nx0>>%LOGFILE%


:Begin
pushd %LGPOPATH%
ECHO %DATE% %TIME% - Info: Running: LGPO.exe /ua "..\..\GPO\%GPO%\%REGPOL%">>%LOGFILE%
ECHO Applying %GPO%
ECHO ****************************************
LGPO.exe /ua "..\..\GPO\%GPO%\%REGPOL%"
popd


:LogEnd
ECHO %DATE% %TIME% - Info: Completed script %~nx0>>%LOGFILE%

ENDLOCAL