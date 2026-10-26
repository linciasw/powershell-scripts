<<<<<<< HEAD
@echo off
setlocal
title First Citizens IT Script Launcher

rem Preserve the old launcher entry point, but use the categorized toolkit menu.
call "%~dp0helpdeskUtility\Start-HelpdeskToolkit.bat"
endlocal
=======
@echo off
setlocal EnableExtensions
title First Citizens IT Script Launcher

rem Move to the repository folder safely, including when launched from a UNC share.
pushd "%~dp0" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not access the scripts folder:
    echo "%~dp0"
    echo.
    echo Check your network connection and permissions.
    pause
    exit /b 1
)

if not exist "helpdeskUtility\Start-HelpdeskToolkit.bat" (
    echo ERROR: Helpdesk toolkit launcher was not found:
    echo "%CD%\helpdeskUtility\Start-HelpdeskToolkit.bat"
    popd
    pause
    exit /b 1
)

call "helpdeskUtility\Start-HelpdeskToolkit.bat"
set "TOOLKIT_EXIT=%ERRORLEVEL%"
popd
endlocal & exit /b %TOOLKIT_EXIT%
>>>>>>> 1f84f8773c3a42f6bc8b4fa6ed9b79b26ec3a15e
