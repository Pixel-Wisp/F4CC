@ECHO off
@ECHO.
@ECHO Deploying F4CC...
@ECHO.

cd /D "%~dp0"
call ..\..\set-paths.cmd
if %errorlevel% neq 0 exit /b %errorlevel%

start /WAIT cmd /C sync_versions.cmd +1
if %errorlevel% neq 0 exit /b %errorlevel%

cd ..\..\Papyrus
start /WAIT cmd /C build.cmd
if %errorlevel% neq 0 exit /b %errorlevel%
cd ..\F4CC-Installer\deploy

CALL "%VSToolsPath%\VsDevCmd.bat"
if %errorlevel% neq 0 exit /b %errorlevel%

cd ..\..\F4SE-Plugin
MSBuild "F4SE-CrowdControl.sln" /p:Configuration=Release /p:Platform="x64"
if %errorlevel% neq 0 exit /b %errorlevel%
md "%FalloutPath%\Data\F4SE\Plugins"
copy /Y ".\x64\Release\CrowdControl.dll" "%FalloutPath%\Data\F4SE\Plugins"
if %errorlevel% neq 0 exit /b %errorlevel%
cd ..\F4CC-Installer\deploy

cd ..\ModArchive
start /WAIT cmd /C build_fomod.cmd
if %errorlevel% neq 0 exit /b %errorlevel%
cd ..\deploy