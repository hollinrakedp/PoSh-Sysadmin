@ECHO Off
goto EndComment
:Comment
Name         - Execute-Custom_GPO_RemovableStorage_NonAdmin_CDDVD_R.bat
Version      - 1.0
Author       - Darren Hollinrake
Date Created - 2018-11-13
Date Updated - 

.SYNOPSIS
Apply the Custom Group Policy for allowing the Non-Administrators group Read access to the local CD/DVD drive.

.NOTES


:EndComment

:Variables
SETLOCAL
set GPO=Custom - User - Removable Storage - Allow CDDVD Read
set REGPOL={02A61DB8-5A3D-43F9-9A11-C6737D91915F}\DomainSysvol\GPO\User\registry.pol

:LogStart
FOR /F "TOKENS=2-4 delims=/ " %%a in ('date /t') do (SET date=%%c%%a%%b)
set LOGFILE="%~dp0ApplyLocalGPO.txt"
ECHO %DATE% %TIME% - Info: Executing script %~nx0>>%LOGFILE%


:Begin
pushd %LGPOPATH%
ECHO %DATE% %TIME% - Info: Running: LGPO.exe /un "..\..\GPO\%GPO%\%REGPOL%">>%LOGFILE%
ECHO Applying %GPO%
ECHO ****************************************
LGPO.exe /un "..\..\GPO\%GPO%\%REGPOL%"
popd


:LogEnd
ECHO %DATE% %TIME% - Info: Completed script %~nx0>>%LOGFILE%

ENDLOCAL