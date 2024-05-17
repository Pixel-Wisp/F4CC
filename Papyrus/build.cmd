@ECHO off
@ECHO.
@ECHO - Building Papyrus...
@ECHO.

call ..\set-paths.cmd
if %errorlevel% neq 0 exit /b %errorlevel%

SET CrowdControlPath=%~dp0
SET ScriptSourcePath="%FalloutPath%\Data\Scripts\Source\"
SET ScriptSourceUserPath="%FalloutPath%\Data\Scripts\Source\User\"
SET ScriptSourceFragmentPath="%FalloutPath%\Data\Scripts\Source\User\Fragments\Quests\"
SET ScriptDataPath="%FalloutPath%\Data\Scripts\"
SET ScriptDataFragmentPath="%FalloutPath%\Data\Scripts\Fragments\Quests\"
SET FalloutDataPath="%FalloutPath%\Data\"
SET CompilerPath="%FalloutPath%\Papyrus Compiler"
SET ArchiveToolPath="%FalloutPath%\Tools\Archive2"
SET ArchiveSource="%CrowdControlPath%archive.source"
SET ArchiveOutput="%FalloutPath%\Data\CrowdControl - Main.ba2"

md %ScriptSourceUserPath%
copy /Y "CrowdControl.psc" %ScriptSourceUserPath%
if %errorlevel% neq 0 exit /b %errorlevel%
copy /Y "CrowdControlApi.psc" %ScriptSourceUserPath%
if %errorlevel% neq 0 exit /b %errorlevel%
md %ScriptSourceFragmentPath%
if not exist %ScriptSourceFragmentPath%QF_CrowdControlQuest_01000F99.psc (
    copy /Y ".\psc\QF_CrowdControlQuest_01000F99.psc" %ScriptSourceFragmentPath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%

md %ScriptSourcePath%
if not exist %ScriptSourcePath%Actor.psc (
    copy /Y ".\psc\Actor.psc" %ScriptSourcePath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%
if not exist %ScriptSourcePath%Form.psc (
    copy /Y ".\psc\Form.psc" %ScriptSourcePath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%
if not exist %ScriptSourcePath%ObjectReference.psc (
    copy /Y ".\psc\ObjectReference.psc" %ScriptSourcePath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%

md %ScriptDataFragmentPath%
if not exist %ScriptDataFragmentPath%QF_CrowdControlQuest_01000F99.pex (
    copy /Y ".\pex\QF_CrowdControlQuest_01000F99.pex" %ScriptDataFragmentPath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%

if not exist %ScriptDataPath%Actor.pex (
    copy /Y ".\pex\Actor.pex" %ScriptDataPath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%
if not exist %ScriptDataPath%Form.pex (
    copy /Y ".\pex\Form.pex" %ScriptDataPath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%
if not exist %ScriptDataPath%ObjectReference.pex (
    copy /Y ".\pex\ObjectReference.pex" %ScriptDataPath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%

copy /Y ".\esp\CrowdControl.esp" %FalloutDataPath%
if %errorlevel% neq 0 exit /b %errorlevel%

cd /D %CompilerPath%
if %errorlevel% neq 0 exit /b %errorlevel%
PapyrusCompiler.exe "%CrowdControlPath%CrowdControlApi.psc" -f="Institute_Papyrus_Flags.flg" -i="%FalloutPath%\Data\Scripts\Source;%FalloutPath%\Data\Scripts\Source\User;%FalloutPath%\Data\Scripts\Source\Base" -o="%FalloutPath%\Data\Scripts" -op
if %errorlevel% neq 0 exit /b %errorlevel%
PapyrusCompiler.exe "%CrowdControlPath%CrowdControl.psc" -f="Institute_Papyrus_Flags.flg" -i="%FalloutPath%\Data\Scripts\Source;%FalloutPath%\Data\Scripts\Source\User;%FalloutPath%\Data\Scripts\Source\Base" -o="%FalloutPath%\Data\Scripts" -op
if %errorlevel% neq 0 exit /b %errorlevel%

SETLOCAL EnableDelayedExpansion
SET PexPath=!FalloutPath!\Data\Scripts\
SET QuestPexPath=!FalloutPath!\Data\Scripts\Fragments\Quests\

(
    echo !PexPath!Actor.pex
    echo !PexPath!CrowdControl.pex
    echo !PexPath!CrowdControlApi.pex
    echo !QuestPexPath!QF_CrowdControlQuest_01000F99.pex
) > "%CrowdControlPath%archive.source"
ENDLOCAL

cd /D %ArchiveToolPath%
Archive2.exe -create=%ArchiveOutput% -sourceFile=%ArchiveSource%
if %errorlevel% neq 0 exit /b %errorlevel%

cd /D %CrowdControlPath%