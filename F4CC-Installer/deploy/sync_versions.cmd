@ECHO OFF
IF "%1" == "" GOTO usage
ECHO %1

:: Get the current version
FOR /F "tokens=*" %%i in ('powershell -command "[regex]::Match((Get-Content -Path '..\AssemblyInfo.cs' -Raw), '\[assembly: AssemblyVersion\(\""(?<select>.*)\""\)').Groups['select'].Value"') do SET CurrentVersion=%%i

:: Increment build
FOR /F "tokens=*" %%i in ('powershell -command "[regex]::Match('%CurrentVersion%', '(\d+)\.(\d+)\.(\d+)\.(\d+)').Groups[4].Value"') do SET CurrentVersionBuild=%%i
SET /A CurrentVersionBuild=%CurrentVersionBuild% + %1
FOR /F "tokens=*" %%i in ('powershell -command "'%CurrentVersion%' -replace '(\d+)\.(\d+)\.(\d+)\.(\d+)', '$1.$2.$3.%CurrentVersionBuild%'"') do SET CurrentVersion=%%i

:: Get the minimum version
FOR /F "tokens=*" %%i in ('powershell -command "'%CurrentVersion%' -replace '(\d+)\.(\d+)\.(\d+)\.(\d+)', '$1.$2.$4'"') do SET CurrentVersionMin=%%i

:: Replace in AssemblyInfo.cs
powershell -command "(Get-Content '..\AssemblyInfo.cs') -replace '\[assembly: AssemblyVersion\(\"".*\""\)\]', '[assembly: AssemblyVersion(\"%CurrentVersion%\")]' | Set-Content '..\AssemblyInfo.cs'"
IF %errorlevel% neq 0 EXIT /b %errorlevel%
powershell -command "(Get-Content '..\AssemblyInfo.cs') -replace '\[assembly: AssemblyFileVersion\(\"".*\""\)\]', '[assembly: AssemblyFileVersion(\"%CurrentVersion%\")]' | Set-Content '..\AssemblyInfo.cs'"
IF %errorlevel% neq 0 EXIT /b %errorlevel%

:: Replace MachineVersion in info.xml
powershell -command "(Get-Content '..\ModArchive\InFomod\fomod\info.xml') -replace 'MachineVersion=\"".+?\""', 'MachineVersion=\"%CurrentVersionMin%\"' | Set-Content '..\ModArchive\InFomod\fomod\info.xml'"
IF %errorlevel% neq 0 EXIT /b %errorlevel%

GOTO end
:usage
ECHO Usage: sync_versions [+1 or -1]
ECHO.
:end