@echo off
setlocal EnableExtensions
title First Citizens IT Helpdesk Toolkit

rem Resolve this folder safely, including when launched from a UNC network share.
pushd "%~dp0" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not access the helpdeskUtility folder:
    echo "%~dp0"
    echo.
    echo Check your network connection and permissions.
    pause
    endlocal
    exit /b 1
)

set "PS_SCRIPT=%CD%\Start-HelpdeskUtility.ps1"

if not exist "%PS_SCRIPT%" (
    echo ERROR: PowerShell utility not found:
    echo "%PS_SCRIPT%"
    echo.
    echo Copy Start-HelpdeskUtility.ps1 into this folder beside this batch file.
    pause
    popd
    endlocal
    exit /b 1
)

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: Windows PowerShell (powershell.exe) was not found.
    pause
    popd
    endlocal
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
set "TOOL_EXIT=%ERRORLEVEL%"

if not "%TOOL_EXIT%"=="0" (
    echo.
    echo The helpdesk utility exited with code %TOOL_EXIT%.
)

echo.
pause
popd
endlocal & exit /b %TOOL_EXIT%
