@ECHO Off
goto EndComment
:Comment
Name         - Execute-Custom_GPO_RemovableStorage_Admin_CDDVD_RW.bat
Version      - 1.0
Author       - Darren Hollinrake
Date Created - 2018-11-13
Date Updated - 

.SYNOPSIS
Apply the Custom Group Policy for allowing the Administrators group Read/Write access to the local CD/DVD drive.

.NOTES


:EndComment

:Variables
SETLOCAL
set GPO=Custom - User - Removable Storage - Allow CDDVD RW
set REGPOL={CA0D9E4D-0A4A-4B02-A47A-2358CC1C37A8}\DomainSysvol\GPO\User\registry.pol

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