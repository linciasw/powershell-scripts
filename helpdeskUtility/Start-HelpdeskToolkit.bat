@echo off
setlocal EnableExtensions
title First Citizens - Helpdesk Toolkit
color 0A

rem CMD cannot use a UNC path as its working directory. PUSHd maps the share
rem to a temporary drive so relative paths and child processes work reliably.
pushd "%~dp0" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not access the toolkit folder:
    echo "%~dp0"
    echo.
    echo Check your network connection and permissions to the Helpdesk share.
    pause
    exit /b 1
)

set "PS_SCRIPT=%CD%\Start-HelpdeskUtility.ps1"

if not exist "%PS_SCRIPT%" (
    echo ERROR: The PowerShell utility is missing.
    echo Expected file:
    echo "%PS_SCRIPT%"
    echo.
    echo The batch menu and PowerShell script must both be deployed to:
    echo   \\pkshares\Helpdesk\Scripts\helpdeskUtility
    echo.
    echo Copy Start-HelpdeskUtility.ps1 from the GitHub helpdeskUtility folder
    echo into the same network folder as this batch file, then try again.
    echo.
    popd
    pause
    exit /b 1
)

:MAIN
cls
echo ============================================================
echo                 HELPDESK TOOLKIT
echo                 First Citizens IT Support
echo ============================================================
echo.
echo   1. User and Access Management
echo   2. Computer Support
echo   3. Troubleshooting and Reports
echo.
echo   0. Exit
echo.
set "choice="
set /p "choice=Select a category: "

if "%choice%"=="1" goto USER_MENU
if "%choice%"=="2" goto COMPUTER_MENU
if "%choice%"=="3" goto TROUBLESHOOT_MENU
if "%choice%"=="0" goto END

echo.
echo Invalid selection. Choose 0, 1, 2, or 3.
pause
goto MAIN

:USER_MENU
cls
echo ============================================================
echo                 USER AND ACCESS MANAGEMENT
echo ============================================================
echo.
echo   1. Create New User
echo   2. Export Email Group Members
echo   3. Export Shared Folder Members
echo.
echo   0. Back to Main Menu
echo.
set "choice="
set /p "choice=Select a task: "

if "%choice%"=="1" (set "TASK=NewUser" & goto RUN_PS)
if "%choice%"=="2" (set "TASK=EmailGroups" & goto RUN_PS)
if "%choice%"=="3" (set "TASK=SharedFolders" & goto RUN_PS)
if "%choice%"=="0" goto MAIN

echo.
echo Invalid selection. Choose 0, 1, 2, or 3.
pause
goto USER_MENU

:COMPUTER_MENU
cls
echo ============================================================
echo                     COMPUTER SUPPORT
echo ============================================================
echo.
echo   1. Get Remote Computer BIOS Serial Number
echo   2. Copy a File to Remote Computers
echo.
echo   0. Back to Main Menu
echo.
set "choice="
set /p "choice=Select a task: "

if "%choice%"=="1" (set "TASK=BiosSerial" & goto RUN_PS)
if "%choice%"=="2" (set "TASK=CopyFile" & goto RUN_PS)
if "%choice%"=="0" goto MAIN

echo.
echo Invalid selection. Choose 0, 1, or 2.
pause
goto COMPUTER_MENU

:TROUBLESHOOT_MENU
cls
echo ============================================================
echo                TROUBLESHOOTING AND REPORTS
echo ============================================================
echo.
echo   1. View File/Folder Permissions
echo   2. Report Largest Folders
echo   3. Report User Profile Sizes
echo   4. Search for Files by Name
echo.
echo   0. Back to Main Menu
echo.
set "choice="
set /p "choice=Select a task: "

if "%choice%"=="1" (set "TASK=Permissions" & goto RUN_PS)
if "%choice%"=="2" (set "TASK=FolderSizes" & goto RUN_PS)
if "%choice%"=="3" (set "TASK=ProfileSizes" & goto RUN_PS)
if "%choice%"=="4" (set "TASK=SearchFiles" & goto RUN_PS)
if "%choice%"=="0" goto MAIN

echo.
echo Invalid selection. Choose 0, 1, 2, 3, or 4.
pause
goto TROUBLESHOOT_MENU

:RUN_PS
cls
echo Running selected helpdesk task...
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -Task "%TASK%"
set "PS_EXIT=%ERRORLEVEL%"
echo.
if not "%PS_EXIT%"=="0" (
    echo PowerShell returned exit code %PS_EXIT%.
) else (
    echo Task finished or returned control.
)
pause
if "%TASK%"=="NewUser" goto USER_MENU
if "%TASK%"=="EmailGroups" goto USER_MENU
if "%TASK%"=="SharedFolders" goto USER_MENU
if "%TASK%"=="BiosSerial" goto COMPUTER_MENU
if "%TASK%"=="CopyFile" goto COMPUTER_MENU
goto TROUBLESHOOT_MENU

:END
popd
endlocal
exit /b 0
