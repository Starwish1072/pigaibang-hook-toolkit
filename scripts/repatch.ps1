# 静默自检：批改邦升级后 app.asar 被覆盖时自动补回 hook（不弹任何窗口）
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$logDir = Join-Path $env:LOCALAPPDATA "pigaibang-hook-toolkit"
$log = Join-Path $logDir "hook-toolkit.log"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
function L($m){ Add-Content $log ((Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "  " + $m) -Encoding UTF8 }
$cands = @((Join-Path $env:LOCALAPPDATA "Programs\pigaibang"), "C:\Program Files\pigaibang", "C:\Program Files (x86)\pigaibang")
$dir = $cands | Where-Object { Test-Path (Join-Path $_ "resources\app.asar") } | Select-Object -First 1
if (-not $dir) { L "auto: 批改邦未安装，跳过"; exit 0 }
$asar = Join-Path $dir "resources\app.asar"
$txt = [Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes($asar))
if ($txt.Contains("PGB Shout Bridge injection")) { exit 0 }
L "auto: 检测到 hook 丢失（批改邦升级？），开始补回"
& (Join-Path $PSScriptRoot "install-hook.ps1") -Silent
