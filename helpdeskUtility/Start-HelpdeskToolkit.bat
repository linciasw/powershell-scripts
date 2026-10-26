@echo off
setlocal EnableExtensions
title First Citizens IT Helpdesk Toolkit

rem pushd maps this UNC folder to a temporary drive before running PowerShell.
pushd "%~dp0" >nul 2>&1
if errorlevel 1 goto :ShareError

set "PS_SCRIPT=%CD%\Start-HelpdeskUtility.ps1"
if not exist "%PS_SCRIPT%" goto :PowerShellScriptMissing

where powershell.exe >nul 2>&1
if errorlevel 1 goto :PowerShellMissing

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
set "TOOL_EXIT=%ERRORLEVEL%"
echo.
if not "%TOOL_EXIT%"=="0" echo The helpdesk utility exited with code %TOOL_EXIT%.
pause
popd
endlocal & exit /b %TOOL_EXIT%

:ShareError
echo ERROR: Could not access the helpdeskUtility folder:
echo "%~dp0"
echo Check your network connection and permissions.
pause
endlocal
exit /b 1

:PowerShellScriptMissing
echo ERROR: PowerShell utility not found:
echo "%PS_SCRIPT%"
echo Copy Start-HelpdeskUtility.ps1 into this folder beside this batch file.
pause
popd
endlocal
exit /b 1

:PowerShellMissing
echo ERROR: Windows PowerShell powershell.exe was not found.
pause
popd
endlocal
exit /b 1
