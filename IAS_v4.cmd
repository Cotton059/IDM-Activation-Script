@set iasver=1.2
@setlocal DisableDelayedExpansion
@echo off
chcp 65001 >nul

title IDM Activation Script %iasver%

set _activate=0
set _freeze=0
set _reset=0

set "PATH=%SystemRoot%\System32;%SystemRoot%\System32\wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"

cls
echo Initializing...

:: Check admin
fltmc >nul 2>&1 || (
    echo.
    echo Please run this script as Administrator!
    pause
    exit /b
)

:: Get architecture
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE') do set arch=%%b

:: ===========================
:: Auto detect IDM path
:: ===========================
setlocal EnableDelayedExpansion
set "IDMan="

:: 1. From registry
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\DownloadManager" /v ExePath 2^>nul') do set "IDMan=%%b"

:: 2. Common paths
if not exist "!IDMan!" (
    for %%i in (
        "%ProgramFiles%\Internet Download Manager\IDMan.exe"
        "%ProgramFiles(x86)%\Internet Download Manager\IDMan.exe"
        "%ProgramW6432%\Internet Download Manager\IDMan.exe"
    ) do (
        if exist "%%~i" set "IDMan=%%~i"
    )
)

:: 3. Search Program Files
if not exist "!IDMan!" (
    for /f "delims=" %%i in ('where /r "%ProgramFiles%" IDMan.exe 2^>nul') do (
        set "IDMan=%%i"
        goto :foundIDM
    )
)

:foundIDM

if not exist "!IDMan!" (
    echo.
    echo IDM not found. Please install it first.
    pause
    exit /b
)

echo.
echo IDM found at:
echo !IDMan!

:: ===========================
:: Menu
:: ===========================
:menu
cls
echo ==========================================
echo         IDM Activation Tool
echo ==========================================
echo.
echo [1] Activate IDM
echo [2] Freeze Trial
echo [3] Reset Activation / Trial
echo.
echo [4] Download IDM
echo [5] Help
echo [0] Exit
echo.
set /p choice=Enter your choice:

if "%choice%"=="1" goto activate
if "%choice%"=="2" goto freeze
if "%choice%"=="3" goto reset
if "%choice%"=="4" start https://www.internetdownloadmanager.com/download.html & goto menu
if "%choice%"=="5" start https://github.com/hanmaoye/IDM-Activation-Script & goto menu
if "%choice%"=="0" exit

goto menu

:: ===========================
:: Activate
:: ===========================
:activate
cls
echo Activating IDM...

taskkill /f /im idman.exe >nul 2>&1

set /a fname=%random% %% 9999 + 1000
set /a lname=%random% %% 9999 + 1000
set email=%fname%.%lname%@tonec.com

reg add "HKCU\Software\DownloadManager" /v FName /t REG_SZ /d "%fname%" /f >nul
reg add "HKCU\Software\DownloadManager" /v LName /t REG_SZ /d "%lname%" /f >nul
reg add "HKCU\Software\DownloadManager" /v Email /t REG_SZ /d "%email%" /f >nul
reg add "HKCU\Software\DownloadManager" /v Serial /t REG_SZ /d "XXXXX-XXXXX-XXXXX-XXXXX" /f >nul

echo.
echo Activation completed.
pause
goto menu

:: ===========================
:: Freeze Trial
:: ===========================
:freeze
cls
echo Freezing trial...

taskkill /f /im idman.exe >nul 2>&1

reg delete "HKCU\Software\DownloadManager" /v "LastCheckQU" /f >nul 2>&1

echo.
echo Trial frozen successfully.
pause
goto menu

:: ===========================
:: Reset
:: ===========================
:reset
cls
echo Resetting IDM...

taskkill /f /im idman.exe >nul 2>&1

reg delete "HKCU\Software\DownloadManager" /f >nul 2>&1

echo.
echo Reset completed.
pause
goto menu