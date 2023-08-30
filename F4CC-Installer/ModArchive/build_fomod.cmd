@echo off
@ECHO.
@ECHO - Building FOMOD...
@ECHO.

call ..\..\set-paths.cmd
if %errorlevel% neq 0 exit /b %errorlevel%

del F4CC_v*

:: Get the current version
FOR /F "tokens=*" %%i in ('powershell -command "[regex]::Match((Get-Content -Path '..\AssemblyInfo.cs' -Raw), '\[assembly: AssemblyVersion\(\""(?<select>.*)\""\)').Groups['select'].Value"') do SET CurrentVersion=%%i
if %errorlevel% neq 0 exit /b %errorlevel%

:: Get the file version (without the build number)
FOR /F "tokens=*" %%i in ('powershell -command "'%CurrentVersion%' -replace '(\d+)\.(\d+)\.(\d+)\.(\d+)', '$1.$2.$4'"') do SET CurrentVersionFile=%%i
if %errorlevel% neq 0 exit /b %errorlevel%

copy /Y "%FalloutPath%\Data\CrowdControl.esp" .\InFomod\
if %errorlevel% neq 0 exit /b %errorlevel%
copy /Y "%FalloutPath%\Data\CrowdControl - Main.ba2" .\InFomod\
if %errorlevel% neq 0 exit /b %errorlevel%
copy /Y "..\..\F4SE-Plugin\x64\Release\CrowdControl.dll" .\InFomod\F4SE\Plugins
if %errorlevel% neq 0 exit /b %errorlevel%
"%SevenZipPath%\7z.exe" a -r -mx9 ".\F4CC_v%CurrentVersionFile%_kmrkle.tv.7z" ".\InFomod\*"
if %errorlevel% neq 0 exit /b %errorlevel%
for %%f in (F4CC_v*) do move /Y "%%f" ..\deploy\Release
if %errorlevel% neq 0 exit /b %errorlevel%