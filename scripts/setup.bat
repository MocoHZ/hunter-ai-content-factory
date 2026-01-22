@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: Hunter AI 内容工厂 - Windows 环境配置脚本
:: 支持: Windows 10/11

title Hunter AI 环境配置

:: ===========================================
:: 颜色定义 (Windows ANSI)
:: ===========================================
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "CYAN=%ESC%[96m"
set "BOLD=%ESC%[1m"
set "NC=%ESC%[0m"

:: ===========================================
:: 主流程
:: ===========================================
echo.
echo %CYAN%%BOLD%╔════════════════════════════════════════════╗%NC%
echo %CYAN%%BOLD%║     🦅 Hunter AI 环境配置脚本 v2.0         ║%NC%
echo %CYAN%%BOLD%╚════════════════════════════════════════════╝%NC%
echo.

:: 检查 Python
call :check_python
if errorlevel 1 goto :error

:: 检查 UV
call :check_uv
if errorlevel 1 goto :error

:: 配置环境
call :setup_env

:: 创建目录
call :setup_directories

:: 安装依赖
call :install_dependencies
if errorlevel 1 goto :error

:: 验证安装
call :verify_installation
if errorlevel 1 goto :error

echo.
echo %GREEN%%BOLD%╔════════════════════════════════════════════╗%NC%
echo %GREEN%%BOLD%║     ✅ 环境配置完成！                       ║%NC%
echo %GREEN%%BOLD%╚════════════════════════════════════════════╝%NC%
echo.
echo %CYAN%下一步:%NC%
echo   1. 编辑 config.yaml 文件，填写 API Key 等配置
echo   2. 运行 %BOLD%uv run hunter config%NC% 检查配置
echo   3. 运行 %BOLD%uv run hunter github%NC% 开始使用
echo.
pause
goto :eof

:: ===========================================
:: 检查 Python
:: ===========================================
:check_python
echo.
echo %BOLD%[1/5] 检查 Python 版本%NC%

where python >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ Python 未安装%NC%
    echo %YELLOW%请从 https://www.python.org/downloads/ 下载 Python 3.12+%NC%
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo %GREEN%✅ Python %PYTHON_VERSION%%NC%

:: 检查版本是否 >= 3.12
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set MAJOR=%%a
    set MINOR=%%b
)
if %MAJOR% LSS 3 (
    echo %YELLOW%⚠️ 需要 Python 3.12+，当前版本 %PYTHON_VERSION%%NC%
    exit /b 1
)
if %MAJOR% EQU 3 if %MINOR% LSS 12 (
    echo %YELLOW%⚠️ 需要 Python 3.12+，当前版本 %PYTHON_VERSION%%NC%
    exit /b 1
)

exit /b 0

:: ===========================================
:: 检查 UV
:: ===========================================
:check_uv
echo.
echo %BOLD%[2/5] 检查 UV 包管理器%NC%

where uv >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%⚠️ UV 未安装，正在安装...%NC%
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

    :: 刷新 PATH
    call refreshenv 2>nul || (
        set "PATH=%USERPROFILE%\.local\bin;%PATH%"
    )

    where uv >nul 2>&1
    if errorlevel 1 (
        echo %RED%❌ UV 安装失败%NC%
        echo %YELLOW%请手动安装: https://github.com/astral-sh/uv%NC%
        exit /b 1
    )
)

for /f "tokens=2" %%i in ('uv --version 2^>^&1') do set UV_VERSION=%%i
echo %GREEN%✅ UV %UV_VERSION%%NC%
exit /b 0

:: ===========================================
:: 配置环境
:: ===========================================
:setup_env
echo.
echo %BOLD%[3/5] 配置环境变量%NC%

if exist ".env" (
    echo %GREEN%✅ .env 文件已存在%NC%
) else if exist ".env.example" (
    copy .env.example .env >nul
    echo %GREEN%✅ .env 文件已从模板创建%NC%
    echo %YELLOW%⚠️ 请编辑 .env 文件填写 API Key%NC%
) else (
    echo %RED%❌ .env.example 模板不存在%NC%
)
exit /b 0

:: ===========================================
:: 创建目录
:: ===========================================
:setup_directories
echo.
echo %BOLD%[4/5] 创建必要目录%NC%

if not exist "data" mkdir data
if not exist "output" mkdir output
echo %GREEN%✅ 目录创建完成 (data/, output/)%NC%
exit /b 0

:: ===========================================
:: 安装依赖
:: ===========================================
:install_dependencies
echo.
echo %BOLD%[5/5] 安装 Python 依赖%NC%
echo %CYAN%ℹ️ 使用 UV 安装依赖...%NC%

uv sync
if errorlevel 1 (
    echo %RED%❌ 依赖安装失败%NC%
    exit /b 1
)

echo %GREEN%✅ 依赖安装完成%NC%
exit /b 0

:: ===========================================
:: 验证安装
:: ===========================================
:verify_installation
echo.
echo %BOLD%[验证] 测试安装%NC%

uv run hunter --version >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ CLI 测试失败%NC%
    exit /b 1
)

for /f "tokens=*" %%i in ('uv run hunter --version 2^>^&1') do set CLI_VERSION=%%i
echo %GREEN%✅ CLI 测试通过: %CLI_VERSION%%NC%
exit /b 0

:: ===========================================
:: 错误处理
:: ===========================================
:error
echo.
echo %RED%环境配置失败，请检查上述错误信息%NC%
pause
exit /b 1
