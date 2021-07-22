@ECHO Off
goto EndComment
:Comment
Name         - Execute-Custom_STIG_Office2010.bat
Version      - 1.0
Author       - Darren Hollinrake
Date Created - 2018-11-10
Date Updated - 

.SYNOPSIS
Apply the Custom Group Policy for Office 2010 against the local machine.

.NOTES


:EndComment

:Variables
SETLOCAL
set STIG=Office 2010 STIG (2018-04-10)
set STIGVER=Custom

:LogStart
FOR /F "TOKENS=2-4 delims=/ " %%a in ('date /t') do (SET date=%%c%%a%%b)
set LOGFILE="%~dp0ApplyLocalGPO.txt"
ECHO %DATE% %TIME% - Info: Executing script %~nx0>>%LOGFILE%


:Begin
pushd %LGPOPATH%
ECHO %DATE% %TIME% - Info: Running: LGPO.exe /g "..\..\GPO\%STIGVER% - %STIG%">>%LOGFILE%
ECHO Applying %STIG% %STIGVER%
ECHO ****************************************
LGPO.exe /g "..\..\GPO\%STIGVER% - %STIG%"
popd


:LogEnd
ECHO %DATE% %TIME% - Info: Completed script %~nx0>>%LOGFILE%

ENDLOCAL