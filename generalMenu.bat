@echo off
setlocal EnableExtensions
title First Citizens IT Script Launcher

rem Move to this script's folder safely, including when launched from a UNC share.
pushd "%~dp0" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not access the scripts folder:
    echo "%~dp0"
    echo.
    echo Check your network connection and permissions.
    pause
    endlocal
    exit /b 1
)

if not exist "helpdeskUtility\Start-HelpdeskToolkit.bat" (
    echo ERROR: Helpdesk toolkit launcher was not found:
    echo "%CD%\helpdeskUtility\Start-HelpdeskToolkit.bat"
    echo.
    echo Confirm the helpdeskUtility folder and launcher are deployed to the share.
    pause
    popd
    endlocal
    exit /b 1
)

call "helpdeskUtility\Start-HelpdeskToolkit.bat"
set "TOOLKIT_EXIT=%ERRORLEVEL%"
popd
endlocal & exit /b %TOOLKIT_EXIT%
