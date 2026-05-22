@echo off
REM ============================================================
REM  VideoAgent Launcher
REM  Opens Claude Code with the full VideoAgent context loaded.
REM
REM  Usage:
REM    video-agent.bat                          Start a session
REM    video-agent.bat --resume                 Resume last session
REM    video-agent.bat --project MyVideo        Set active project
REM    video-agent.bat --instance experimental  Use named instance
REM    video-agent.bat --comfyui URL            Override ComfyUI URL directly
REM
REM  Instance names are defined in config\instances.json
REM  Copy config\instances.example.json to config\instances.json to get started.
REM ============================================================

setlocal enabledelayedexpansion

REM Resolve to the directory where this bat file lives (strips trailing backslash)
set "REPO_DIR=%~dp0"
if "%REPO_DIR:~-1%"=="\" set "REPO_DIR=%REPO_DIR:~0,-1%"
set "CLAUDE_ARGS="
set "ACTIVE_PROJECT="
set "ACTIVE_INSTANCE="
set "COMFYUI_URL="

REM Parse arguments
:parse_args
if "%~1"=="" goto :done_args
if /i "%~1"=="--resume" (
    set "CLAUDE_ARGS=--resume"
    shift
    goto :parse_args
)
if /i "%~1"=="--project" (
    set "ACTIVE_PROJECT=%~2"
    shift & shift
    goto :parse_args
)
if /i "%~1"=="--instance" (
    set "ACTIVE_INSTANCE=%~2"
    shift & shift
    goto :parse_args
)
if /i "%~1"=="--comfyui" (
    set "COMFYUI_URL=%~2"
    shift & shift
    goto :parse_args
)
shift
goto :parse_args
:done_args

REM ----------------------------------------------------------------
REM Resolve ComfyUI URL
REM Priority: --comfyui > --instance > project manifest > instances.json default > fallback
REM ----------------------------------------------------------------
set "INSTANCES_JSON=%REPO_DIR%\config\instances.json"

REM If --instance was given (and no direct --comfyui), resolve from instances.json
if not defined COMFYUI_URL (
    if defined ACTIVE_INSTANCE (
        if exist "%INSTANCES_JSON%" (
            for /f "delims=" %%U in ('pwsh -NoProfile -Command "$cfg = Get-Content '%INSTANCES_JSON%' -Raw | ConvertFrom-Json; $cfg.instances.'%ACTIVE_INSTANCE%'.url" 2^>nul') do set "COMFYUI_URL=%%U"
        )
        if not defined COMFYUI_URL (
            echo  [WARN] Instance '%ACTIVE_INSTANCE%' not found in instances.json. Using fallback.
        )
    )
)

REM If still no URL, check if --project has a preferred instance in its manifest
if not defined COMFYUI_URL (
    if defined ACTIVE_PROJECT (
        set "MANIFEST=%REPO_DIR%\projects\%ACTIVE_PROJECT%\manifest.yaml"
        if exist "!MANIFEST!" (
            for /f "tokens=2 delims=: " %%I in ('findstr /i "comfyui_instance" "!MANIFEST!" 2^>nul') do (
                if not defined ACTIVE_INSTANCE set "ACTIVE_INSTANCE=%%I"
            )
            if defined ACTIVE_INSTANCE (
                if exist "%INSTANCES_JSON%" (
                    for /f "delims=" %%U in ('pwsh -NoProfile -Command "$cfg = Get-Content '%INSTANCES_JSON%' -Raw | ConvertFrom-Json; $cfg.instances.'!ACTIVE_INSTANCE!'.url" 2^>nul') do set "COMFYUI_URL=%%U"
                )
            )
        )
    )
)

REM If still no URL, use default from instances.json
if not defined COMFYUI_URL (
    if exist "%INSTANCES_JSON%" (
        for /f "delims=" %%U in ('pwsh -NoProfile -Command "$cfg = Get-Content '%INSTANCES_JSON%' -Raw | ConvertFrom-Json; $def = $cfg.default; $cfg.instances.$def.url" 2^>nul') do set "COMFYUI_URL=%%U"
        if not defined ACTIVE_INSTANCE (
            for /f "delims=" %%I in ('pwsh -NoProfile -Command "$cfg = Get-Content '%INSTANCES_JSON%' -Raw | ConvertFrom-Json; $cfg.default" 2^>nul') do set "ACTIVE_INSTANCE=%%I"
        )
    )
)

REM Final fallback
if not defined COMFYUI_URL set "COMFYUI_URL=http://127.0.0.1:8188"

REM ----------------------------------------------------------------
REM Write active session config (read by CLAUDE.md at session start)
REM ----------------------------------------------------------------
(
echo {
echo   "comfyui_url": "%COMFYUI_URL%",
echo   "active_instance": "%ACTIVE_INSTANCE%",
echo   "active_project": "%ACTIVE_PROJECT%",
echo   "started": "%date% %time%"
echo }
) > "%REPO_DIR%\state\session.json"

REM Launch Claude Code in the VideoAgent directory
cd /d "%REPO_DIR%"
echo.
echo  VideoAgent Session
echo  ==================
echo  Project dir: %REPO_DIR%
if defined ACTIVE_PROJECT echo  Project:     %ACTIVE_PROJECT%
if defined ACTIVE_INSTANCE echo  Instance:    %ACTIVE_INSTANCE%
echo  ComfyUI:     %COMFYUI_URL%
echo.
if not exist "%INSTANCES_JSON%" (
    echo  [TIP] Copy config\instances.example.json to config\instances.json
    echo        to configure named ComfyUI instances.
    echo.
)

claude %CLAUDE_ARGS%

endlocal
