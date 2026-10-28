@echo off
setlocal EnableExtensions
title First Citizens IT Script Launcher

rem pushd maps a UNC path to a temporary drive before invoking CMD-based scripts.
pushd "%~dp0" >nul 2>&1
if errorlevel 1 goto :ShareError

if not exist "helpdeskUtility\Start-HelpdeskToolkit.bat" goto :ToolkitMissing

call "helpdeskUtility\Start-HelpdeskToolkit.bat"
set "TOOLKIT_EXIT=%ERRORLEVEL%"
popd
endlocal & exit /b %TOOLKIT_EXIT%

:ShareError
echo ERROR: Could not access the scripts folder:
echo "%~dp0"
echo Check your network connection and permissions.
pause
endlocal
exit /b 1

:ToolkitMissing
echo ERROR: Helpdesk toolkit launcher was not found:
echo "%~dp0helpdeskUtility\Start-HelpdeskToolkit.bat"
echo Confirm the helpdeskUtility folder and launcher are deployed to the share.
pause
popd
endlocal
exit /b 1
