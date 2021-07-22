@ECHO Off
goto EndComment
:Comment
Name         - Execute-DoD_STIG_WindowsDefender.bat
Version      - 1.0
Author       - Darren Hollinrake
Date Created - 2018-11-10
Date Updated - 

.SYNOPSIS
Apply the DISA Group Policy for Windows Defender Antivirus against the local machine.

.NOTES


:EndComment

:Variables
SETLOCAL
set STIG=DoD Windows Defender Antivirus STIG
set STIGVER=v1r4

:LogStart
FOR /F "TOKENS=2-4 delims=/ " %%a in ('date /t') do (SET date=%%c%%a%%b)
set LOGFILE="%~dp0ApplyLocalGPO.txt"
ECHO %DATE% %TIME% - Info: Executing script %~nx0>>%LOGFILE%


:Begin
pushd %LGPOPATH%
ECHO %DATE% %TIME% - Info: Running: LGPO.exe /g "..\..\GPO\%STIG% %STIGVER%\GPO">>%LOGFILE%
ECHO Applying %STIG% %STIGVER%
ECHO ****************************************
LGPO.exe /g "..\..\GPO\%STIG% %STIGVER%\GPO"
popd


:LogEnd
ECHO %DATE% %TIME% - Info: Completed script %~nx0>>%LOGFILE%

ENDLOCAL