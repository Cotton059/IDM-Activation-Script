@set iasver=1.2
@setlocal DisableDelayedExpansion
@echo off
chcp 65001 >nul

:: 中文标题
title IDM 激活脚本 %iasver%

:: 参数
set _activate=0
set _freeze=0
set _reset=0

:: 修复 PATH
set "PATH=%SystemRoot%\System32;%SystemRoot%\System32\wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"

:: 初始化
cls
echo 正在初始化...

:: 检查管理员权限
fltmc >nul 2>&1 || (
    echo.
    echo 请以管理员身份运行本脚本！
    pause
    exit /b
)

:: 获取系统架构
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE') do set arch=%%b

:: ===========================
:: ✅ 自动查找 IDM 路径（优化）
:: ===========================
setlocal EnableDelayedExpansion
set "IDMan="

:: 1. 注册表读取
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\DownloadManager" /v ExePath 2^>nul') do set "IDMan=%%b"

:: 2. 常见路径
if not exist "!IDMan!" (
    for %%i in (
        "%ProgramFiles%\Internet Download Manager\IDMan.exe"
        "%ProgramFiles(x86)%\Internet Download Manager\IDMan.exe"
        "%ProgramW6432%\Internet Download Manager\IDMan.exe"
    ) do (
        if exist "%%~i" set "IDMan=%%~i"
    )
)

:: 3. 搜索 Program Files
if not exist "!IDMan!" (
    for /f "delims=" %%i in ('where /r "%ProgramFiles%" IDMan.exe 2^>nul') do (
        set "IDMan=%%i"
        goto :foundIDM
    )
)

:foundIDM

if not exist "!IDMan!" (
    echo.
    echo ❌ 未检测到 IDM，请先安装！
    pause
    exit /b
)

echo.
echo ✔ 已找到 IDM 路径：
echo !IDMan!

:: ===========================
:: 主菜单
:: ===========================
:menu
cls
echo ==========================================
echo              IDM 激活工具
echo ==========================================
echo.
echo [1] 激活 IDM
echo [2] 冻结试用期
echo [3] 重置激活 / 试用
echo.
echo [4] 下载 IDM
echo [5] 帮助说明
echo [0] 退出脚本
echo.
set /p choice=请输入选项：

if "%choice%"=="1" goto activate
if "%choice%"=="2" goto freeze
if "%choice%"=="3" goto reset
if "%choice%"=="4" start https://www.internetdownloadmanager.com/download.html & goto menu
if "%choice%"=="5" start https://github.com/hanmaoye/IDM-Activation-Script & goto menu
if "%choice%"=="0" exit

goto menu

:: ===========================
:: 激活
:: ===========================
:activate
cls
echo 正在执行激活...

taskkill /f /im idman.exe >nul 2>&1

:: 随机信息
set /a fname=%random% %% 9999 + 1000
set /a lname=%random% %% 9999 + 1000
set email=%fname%.%lname%@tonec.com

:: 写入注册表
reg add "HKCU\Software\DownloadManager" /v FName /t REG_SZ /d "%fname%" /f >nul
reg add "HKCU\Software\DownloadManager" /v LName /t REG_SZ /d "%lname%" /f >nul
reg add "HKCU\Software\DownloadManager" /v Email /t REG_SZ /d "%email%" /f >nul
reg add "HKCU\Software\DownloadManager" /v Serial /t REG_SZ /d "XXXXX-XXXXX-XXXXX-XXXXX" /f >nul

echo.
echo ✔ IDM 激活已完成
pause
goto menu

:: ===========================
:: 冻结试用
:: ===========================
:freeze
cls
echo 正在冻结试用期...

taskkill /f /im idman.exe >nul 2>&1

reg delete "HKCU\Software\DownloadManager" /v "LastCheckQU" /f >nul 2>&1

echo.
echo ✔ 试用期已冻结
pause
goto menu

:: ===========================
:: 重置
:: ===========================
:reset
cls
echo 正在重置 IDM 状态...

taskkill /f /im idman.exe >nul 2>&1

reg delete "HKCU\Software\DownloadManager" /f >nul 2>&1

echo.
echo ✔ 已重置完成（恢复初始状态）
pause
goto menu