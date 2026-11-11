@echo off
chcp 65001 >nul
setlocal
title 安装：每 30 分钟静默检查 Hook
set "HERE=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$vbs = Join-Path '%HERE%' 'scripts\repatch-hidden.vbs'; ^
   $a = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument ('"' + $vbs + '"'); ^
   $t1 = New-ScheduledTaskTrigger -AtLogOn; ^
   $t2 = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 30); ^
   Register-ScheduledTask -TaskName 'PGB-Hook-AutoRepatch' -Action $a -Trigger @($t1,$t2) -Description '批改邦升级后自动补回 Hook（静默）' -Force | Out-Null; ^
   Write-Host '已安装计划任务 PGB-Hook-AutoRepatch（登录时 + 每 30 分钟，静默无窗口）'"
echo.
pause
