@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: Hunter AI 内容工厂 - Windows 统一启动脚本
:: 使用方法: run.bat [命令]

title Hunter AI 内容工厂

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

:: 切换到项目根目录
cd /d "%~dp0.."

:: ===========================================
:: 环境预检
:: ===========================================
:precheck
:: 检查 UV
where uv >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%⚠️ UV 未安装，正在运行环境配置...%NC%
    call scripts\setup.bat
    if errorlevel 1 goto :error
)

:: 检查依赖
if not exist ".venv" (
    echo %YELLOW%⚠️ 依赖未安装，正在安装...%NC%
    uv sync
    if errorlevel 1 goto :error
)

:: 检查 .env
if not exist ".env" (
    if exist ".env.example" (
        copy .env.example .env >nul
        echo %YELLOW%⚠️ 已创建 .env 文件，请编辑填写 API Key%NC%
        echo.
    )
)

:: ===========================================
:: 命令路由
:: ===========================================
if "%1"=="" goto :help
if "%1"=="help" goto :help
if "%1"=="github" goto :github
if "%1"=="pain" goto :pain
if "%1"=="publish" goto :publish
if "%1"=="refine" goto :refine
if "%1"=="all" goto :all
if "%1"=="config" goto :config
if "%1"=="setup" goto :setup
if "%1"=="clean" goto :clean
if "%1"=="check" goto :check

echo %RED%❌ 未知命令: %1%NC%
goto :help

:: ===========================================
:: 命令实现
:: ===========================================
:help
echo.
echo %CYAN%%BOLD%========================================%NC%
echo %CYAN%%BOLD%  🦅 Hunter AI 内容工厂 v2.0%NC%
echo %CYAN%%BOLD%========================================%NC%
echo.
echo %GREEN%可用命令:%NC%
echo.
echo   %CYAN%github%NC%    - 🐙 运行 GitHub 猎手（搜索高星开源项目）
echo   %CYAN%pain%NC%      - 📡 运行痛点雷达（扫描 Twitter 抱怨）
echo   %CYAN%publish%NC%   - 🚀 运行全能猎手（综合采集+写作）
echo   %CYAN%refine%NC%    - 🔄 运行内容精炼器（深度洗稿）
echo   %CYAN%all%NC%       - 🔥 全员出击（运行所有模块）
echo   %CYAN%config%NC%    - ⚙️  显示当前配置
echo   %CYAN%setup%NC%     - 📦 重新配置环境
echo   %CYAN%check%NC%     - 🔍 环境自检
echo   %CYAN%clean%NC%     - 🧹 清理缓存
echo   %CYAN%help%NC%      - 📖 显示帮助
echo.
echo %YELLOW%示例:%NC%
echo   run.bat github
echo   run.bat all
echo.
goto :eof

:github
echo %CYAN%%BOLD%🐙 启动 GitHub 猎手...%NC%
uv run hunter github
goto :eof

:pain
echo %CYAN%%BOLD%📡 启动痛点雷达...%NC%
uv run hunter pain
goto :eof

:publish
echo %CYAN%%BOLD%🚀 启动全能猎手...%NC%
uv run hunter publish
goto :eof

:refine
echo %CYAN%%BOLD%🔄 启动内容精炼器...%NC%
uv run hunter refine
goto :eof

:all
echo %CYAN%%BOLD%🔥 全员出击模式...%NC%
uv run hunter all
goto :eof

:config
uv run hunter config
goto :eof

:setup
call scripts\setup.bat
goto :eof

:check
echo %CYAN%%BOLD%🔍 运行环境自检...%NC%
uv run python -m src.bootstrap
goto :eof

:clean
echo %CYAN%%BOLD%🧹 清理缓存...%NC%
if exist "__pycache__" rd /s /q __pycache__
if exist ".pytest_cache" rd /s /q .pytest_cache
for /d /r %%d in (__pycache__) do if exist "%%d" rd /s /q "%%d"
for /r %%f in (*.pyc) do if exist "%%f" del /q "%%f"
echo %GREEN%✅ 缓存清理完成%NC%
goto :eof

:error
echo %RED%❌ 执行失败%NC%
pause
exit /b 1
