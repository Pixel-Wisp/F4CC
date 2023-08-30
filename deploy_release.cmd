@ECHO off
@ECHO.
@ECHO Deploying F4CC...
@ECHO.
SET CrowdControlPath="%~dp0"
cd /D "%~dp0"
cd ".\F4CC-Installer\deploy"
call "deploy_Release.cmd"
if %errorlevel% neq 0 goto ERROR
cd /D "%CrowdControlPath%"
@ECHO.
@ECHO F4CC deployed.
@ECHO.
@goto END
:ERROR
@cd /D "%CrowdControlPath%"
@ECHO.
@ECHO.
@ECHO ERROR ENCOUNTERED !
@ECHO ERROR ENCOUNTERED !
@ECHO ERROR ENCOUNTERED !
@ECHO ERROR ENCOUNTERED !
@ECHO ERROR ENCOUNTERED !
@ECHO.
@pause
@ECHO.
:END