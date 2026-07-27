@echo off
title PowerShell Script Launcher
color 0A

:MENU
cls
echo =====================================
echo      PowerShell Script Launcher
echo =====================================
echo.
echo 1. Generate Usernames
echo 2. Create New Users
echo 3. 
echo.
echo 0. Exit
echo.

set /p choice=Select an option: 

if "%choice%"=="1" goto Usernames
if "%choice%"=="2" goto NewUser
if "%choice%"=="3" goto Script3
if "%choice%"=="0" exit

echo.
echo Invalid selection.
pause
goto MENU


:Usernames
echo.
echo Running usernames.ps1...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0usernames.ps1"
pause
goto MENU


:NewUser
echo.
echo Running newUser.ps1...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0newUser.ps1"
pause
goto MENU


:Script3
echo.
echo Add your PowerShell script here...
REM Example:
REM powershell.exe -ExecutionPolicy Bypass -File "%~dp0YourScript.ps1"
pause
goto MENU