@echo off
chcp 65001 >nul
setlocal
title 批改邦 一键恢复（移除 Hook）
set "HERE=%~dp0"
if /i "%~1"=="silent" (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%HERE%scripts\restore.ps1" -Silent
  exit /b %errorlevel%
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%HERE%scripts\restore.ps1"
echo.
echo 日志: %LOCALAPPDATA%\pigaibang-hook-toolkit\hook-toolkit.log
pause
