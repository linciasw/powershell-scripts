@echo off
setlocal
title First Citizens IT Script Launcher

rem Preserve the old launcher entry point, but use the categorized toolkit menu.
call "%~dp0helpdeskUtility\Start-HelpdeskToolkit.bat"
endlocal
