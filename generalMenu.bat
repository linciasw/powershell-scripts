@echo off
title First Citizens IT Script Launcher
color 0A

:MENU
cls
echo ====================================================
echo           FIRST CITIZENS IT SCRIPT LAUNCHER
echo ====================================================
echo.
echo   1. Export Email Group Members
echo   2. Export Shared Folder Members
echo   3. New Users
echo   4.
echo   5.
echo   6.
echo   7.
echo   8.
echo.
echo ----------------------------------------------------
echo   0. Exit
echo ----------------------------------------------------
echo.

set /p choice=Select an option: 

if "%choice%"=="1" goto EMAILGROUPS
if "%choice%"=="2" goto SHAREDFOLDERS
if "%choice%"=="3" goto NEWUSERS
if "%choice%"=="4" goto NOTREADY
if "%choice%"=="5" goto NOTREADY
if "%choice%"=="6" goto NOTREADY
if "%choice%"=="7" goto NOTREADY
if "%choice%"=="8" goto NOTREADY
if "%choice%"=="0" exit

echo.
echo Invalid selection.
pause
goto MENU

:EMAILGROUPS
cls
echo Running Export Email Group Members...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\pkshares\Helpdesk\Scripts\emailGroupMembers\emailGroups.ps1"
echo.
pause
goto MENU

:SHAREDFOLDERS
cls
echo Running Export Shared Folder Members...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\pkshares\Helpdesk\Scripts\sharedFolderMembers\sharedFolder.ps1"
echo.
pause
goto MENU

:NEWUSERS
cls
echo Running New Users...
echo.
call "\\pkshares\Helpdesk\Scripts\newUser\newUser.bat"
echo.
pause
goto MENU

:NOTREADY
cls
echo This option has not been assigned yet.
echo.
pause
goto MENU