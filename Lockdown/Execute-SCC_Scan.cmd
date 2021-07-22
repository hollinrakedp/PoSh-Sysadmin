@ECHO OFF
ECHO.
ECHO ################################################################################
ECHO #                                                                              #
ECHO #                           SCAP Compliance Checker                            #
ECHO #                                                                              #
ECHO ################################################################################
ECHO.
ECHO                   Verifying we have administrative priviliges                  
ECHO.
WHOAMI /Groups | FIND "12288" >NUL
IF ERRORLEVEL 1 (
	ECHO.
	ECHO ************************************************************
	ECHO *         Administrive priviliges were not found!          *
	ECHO *                                                          *
	ECHO *       Please re-run from an elevated command prompt      *
	ECHO *                         EXITING!                         *
	ECHO ************************************************************
	Timeout 10
	Exit /B 1
	)
ECHO.
ECHO             Running a scan using the options defined in: options.xml            
ECHO.

:: Make the script directory the current directory
PUSHD %~dp0
cd "C:\Program Files\SCAP Compliance Checker 5.0.2"
cscc.exe
POPD

ECHO.
ECHO ################################################################################
ECHO #                                                                              #
ECHO #                               Scan Completed                                 #
ECHO #                                                                              #
ECHO ################################################################################
ECHO.            
ECHO.
Timeout 10