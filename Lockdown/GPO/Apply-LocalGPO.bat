@ECHO Off
goto EndComment
:Comment
Name         - Apply-LocalGPO.bat
Version      - 2.0
Author       - Darren Hollinrake
Date Created - 2018-04-21
Date Updated - 2018-11-13

.SYNOPSIS
Apply Group Policy against the local machine.

.NOTES
Version 2.X is a major overhaul of the script. Applying GPO's can now be limited to specific ones by using parameters.

This is the control script for applying the specified GPO's against the local machine. Run the script with parameters to apply specific GPO's. If no parameters are specified when the script is ran, the default set is used.
This script is set to lock down removable storage in the default set. Only administrators are given RW access to the CD/DVD drive and removable drives.

STIGS in the default set:	Windows 10
                        	Office 2010
                        	Office 2013
                        	Office 2016
                        	Windows Firewall
                        	Windows Defender
                        	IE11

GPO's in the default set:	Custom - AppLocker - Audit Only
                        	Custom - Disable CEIP
                        	Custom - Disable Cortana
                        	Custom - Display Previous Logon Info
                        	Custom - Do Not Display Last User Name
                        	Custom - Require Ctrl Alt Del
                        	Custom - User - Removable Storage - Allow CDDVD RW
                        	Custom - User - Removable Storage - Allow Rem Drive RW
                        	Custom - User - Removable Storage - Deny Any
	
Available parameters:	        /AdminCDRW
                                /AdminRemDriveRW
                                /NonAdminCDRead
                                /AppLockerAudit
                                /AppLockerEnforce
                                /Defender
                                /DisableCortana
                                /DisableCEIP
                                /DisableRemovableStorage
                                /DisplayLogonInfo
                                /IE11
                                /Firewall
                                /NBFOUO
                                /NBSecret
                                /NBSecretNoForn
                                /NBTest
                                /NBUnclass
                                /NoPreviousUser
                                /Office2010
                                /Office2013
                                /Office2016
                                /RequireCtrlAltDel
                                /Windows10



:EndComment

SETLOCAL

:LogStart
FOR /F "TOKENS=2-4 delims=/ " %%a in ('date /t') do (SET date=%%c%%a%%b)
set LOGFILE="%~dp0ApplyLocalGPO.txt"
ECHO ********************************************************************************>>%LOGFILE%
ECHO %DATE% %TIME% - Info: Executing script: %~nx0>>%LOGFILE%

title %~n0 %*

:CheckPrivilege
WHOAMI /Groups | FIND "12288" >NUL
IF ERRORLEVEL 1 (
	ECHO Elevated privileges are required but none were detected. Exiting...
	EXIT /B 1
)
pushd "%~dp0"

:CheckBit
ECHO Checking OS Architecture
IF "%processor_architecture%"=="AMD64" (
	SET bit=x64
	SET lgpo=LGPO\x64
	GOTO LGPOPATH
	) ELSE (
	SET bit=x86
	SET lgpo=LGPO\x64
	GOTO LGPOPATH
	)

:LGPOPATH
ECHO Detected: %bit%
pushd "..\%lgpo%"
SET LGPOPATH=%CD%
ECHO %LGPOPATH%
popd

:InitialEval
if "%1"=="" goto DefaultSet

:EvalParams
if "%1"=="" goto NoMoreParams
for %%i in (/AdminCDRW /AdminRemDriveRW /NonAdminCDRead /AppLockerAudit /AppLockerEnforce /Defender /DisableCortana /DisableCEIP /DisableRemovableStorage /DisplayLogonInfo /IE11 /Firewall /NBFOUO /NBSecret /NBSecretNoForn /NBTest /NBUnclass /NoPreviousUser /Office2010 /Office2013 /Office2016 /RequireCtrlAltDel /Windows10) do (
  if /i "%1"=="%%i" ECHO %DATE% %TIME% - Info: Option %%i detected>>%LOGFILE%
)
if /i "%1"=="/AdminCDRW" set ADMINCDRW=true
if /i "%1"=="/AdminRemDriveRW" set ADMINREMDRIVERW=true
if /i "%1"=="/NonAdminCDRead" set NONADMINCDREAD=true
if /i "%1"=="/AcroProDCClassic" set ACROPRODCCLASS=true
if /i "%1"=="/AcroProDCCont" set ACROPRODCCONT=true
if /i "%1"=="/AppLockerAudit" set APPLOCKERAUDIT=true
if /i "%1"=="/AppLockerEnforce" set APPLOCKERENFORCE=true
if /i "%1"=="/Defender" set DEFENDER=true
if /i "%1"=="/DisableCortana" set DISABLECORTANA=true
if /i "%1"=="/DisableCEIP" set DISABLECEIP=true
if /i "%1"=="/DisableRemovableStorage" set DISABLEREMSTORAGE=true
if /i "%1"=="/DisplayLogonInfo" set DISPLAYLOGONINFO=true
if /i "%1"=="/IE11" set IE11=true
if /i "%1"=="/Firewall" set FIREWALL=true
if /i "%1"=="/NBFOUO" set NBFOUO=true
if /i "%1"=="/NBSecret" set NBSECRET=true
if /i "%1"=="/NBSecretNoForn" set NBSECNOFORN=true
if /i "%1"=="/NBTest" set NBTEST=true
if /i "%1"=="/NBUnclass" set NBUNCLASS=true
if /i "%1"=="/NoPreviousUser" set PREVIOUSUSER=true
if /i "%1"=="/Office2010" set OFFICE2010=true
if /i "%1"=="/Office2013" set OFFICE2013=true
if /i "%1"=="/Office2016" set OFFICE2016=true
if /i "%1"=="/RequireCtrlAltDel" set CTRLALTDEL=true
if /i "%1"=="/Windows10" set WIN10=true

shift /1
goto EvalParams

:DefaultSet
ECHO %DATE% %TIME% - Info: No parameters detected. Using the default set.>>%LOGFILE%
set AdminCDRW=true
set AdminRemDriveRW=true
set APPLOCKERAUDIT=true
set DEFENDER=true
set DISABLECORTANA=true
set DISABLECEIP=true
set DISABLEREMSTORAGE=true
set DISPLAYLOGONINFO=true
set IE11=true
set FIREWALL=true
set PREVIOUSUSER=true
set OFFICE2010=true
set OFFICE2013=true
set OFFICE2016=true
set CTRLALTDEL=true
set WIN10=true

:NoMoreParams

ECHO.
ECHO ********************************************************************************
ECHO *                                                                              *
ECHO *             Applying the selected GPOs against the local computer            *
ECHO *                                                                              *
ECHO ********************************************************************************
ECHO.


:ApplyGPO

if "%ACROPRODCCLASS%" NEQ "true" goto SkipAcroProDCClassic
Call "%~dp0Execute-DoD_STIG_AcrobatProDCClassic.bat"
ECHO.

:SkipAcroProDCClassic


if "%ACROPRODCCLASS%" NEQ "true" goto SkipAcroProDCCont
Call "%~dp0Execute-DoD_STIG_AcrobatProDCContinuous.bat"
ECHO.

:SkipAcroProDCCont


if "%APPLOCKERAUDIT%" NEQ "true" goto SkipAppLockerAudit
Call "%~dp0Execute-Custom_GPO_AppLockerAudit.bat"
ECHO.

:SkipAppLockerAudit

if "%APPLOCKERENFORCE%" NEQ "true" goto SkipAppLockerEnforce
Call "%~dp0Execute-Custom_GPO_AppLockerEnforce.bat"
ECHO.

:SkipAppLockerEnforce


if "%DEFENDER%" NEQ "true" goto SkipDefender
Call "%~dp0Execute-DoD_STIG_WindowsDefender.bat"
ECHO.

:SkipDefender


if "%DISABLECORTANA%" NEQ "true" goto SkipDisableCortana
Call "%~dp0Execute-Custom_GPO_DisableCortana.bat"
ECHO.

:SkipDisableCortana


if "%DISABLECEIP%" NEQ "true" goto SkipDisableCEIP
Call "%~dp0Execute-Custom_GPO_DisableCEIP.bat"
ECHO.

:SkipDisableCEIP


if "%DISABLEREMSTORAGE%" NEQ "true" goto SkipDisableRemovableStorage
Call "%~dp0Execute-Custom_GPO_RemovableStorage_DenyAny.bat"
ECHO.

:SkipDisableRemovableStorage


if "%ADMINCDRW%" NEQ "true" goto SkipAdminCDRW
Call "%~dp0Execute-Custom_GPO_RemovableStorage_Admin_CDDVD_RW.bat"
ECHO.

:SkipAdminCDRW


if "%ADMINREMDRIVERW%" NEQ "true" goto SkipAdminRemDriveRW
Call "%~dp0Execute-Custom_GPO_RemovableStorage_Admin_RemDrive_RW.bat"
ECHO.

:SkipAdminRemDriveRW


if "%NONADMINCDREAD%" NEQ "true" goto SkipNonAdminCDRead
Call "%~dp0Execute-Custom_GPO_RemovableStorage_NonAdmin_CDDVD_R.bat"
ECHO.

:SkipNonAdminCDRead


if "%DISPLAYLOGONINFO%" NEQ "true" goto SkipDisplayLogonInfo
Call "%~dp0Execute-Custom_GPO_DisplayPreviousLogonInfo.bat"
ECHO.

:SkipDisplayLogonInfo


if "%IE11%" NEQ "true" goto SkipIE11
Call "%~dp0Execute-DoD_STIG_IE11.bat"
ECHO.

:SkipIE11


if "%FIREWALL%" NEQ "true" goto SkipFirewall
Call "%~dp0Execute-DoD_STIG_WindowsFirewall.bat"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '..\New-FirewallLogFolder.ps1'"
ECHO.

:SkipFirewall


if "%NBTEST%" NEQ "true" goto SkipNBTest
Call "%~dp0Execute-Custom_GPO_NetBanner_Test.bat"
ECHO.

:SkipNBTest


if "%NBUNCLASS%" NEQ "true" goto SkipNBUnclass
Call "%~dp0Execute-Custom_GPO_NetBanner_Unclass.bat"
ECHO.

:SkipNBUnclass


if "%NBFOUO%" NEQ "true" goto SkipNBFOUO
Call "%~dp0Execute-Custom_GPO_NetBanner_FOUO.bat"
ECHO.

:SkipNBFOUO


if "%NBSECRET%" NEQ "true" goto SkipNBSecret
Call "%~dp0Execute-Custom_GPO_NetBanner_Secret.bat"
ECHO.

:SkipNBSecret


if "%NBSECNOFORN%" NEQ "true" goto SkipNBSecretNoForn
Call "%~dp0Execute-Custom_GPO_NetBanner_SecretNoForn.bat"
ECHO.

:SkipNBSecretNoForn


if "%PREVIOUSUSER%" NEQ "true" goto SkipPreviousUser
Call "%~dp0Execute-Custom_GPO_DoNotDisplayLastUserName.bat"
ECHO.

:SkipPreviousUser


if "%OFFICE2010%" NEQ "true" goto SkipOffice2010
Call "%~dp0Execute-Custom_STIG_Office2010.bat"
ECHO.

:SkipOffice2010


if "%OFFICE2013%" NEQ "true" goto SkipOffice2013
Call "%~dp0Execute-DoD_STIG_Office2013.bat"
ECHO.

:SkipOffice2013


if "%OFFICE2016%" NEQ "true" goto SkipOffice2016
Call "%~dp0Execute-DoD_STIG_Office2016.bat"
ECHO.

:SkipOffice2016


if "%CTRLALTDEL%" NEQ "true" goto SkipCtrlAltDel
Call "%~dp0Execute-Custom_GPO_RequireCtrlAltDel.bat"
ECHO.

:SkipCtrlAltDel


if "%WIN10%" NEQ "true" goto SkipWin10
Call "%~dp0Execute-DoD_STIG_Windows10.bat"
ECHO.

:SkipWin10

ECHO.
ECHO ********************************************************************************
ECHO *                                                                              *
ECHO *                            Applying GPOs Completed                           *
ECHO *                                                                              *
ECHO ********************************************************************************
ECHO.

:LogEnd
ECHO %DATE% %TIME% - Info: Completed execution of script: %~nx0>>%LOGFILE%
ECHO ********************************************************************************>>%LOGFILE%

ENDLOCAL