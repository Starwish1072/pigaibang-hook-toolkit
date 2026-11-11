# 一键恢复：从最近的备份还原批改邦 app.asar（去掉 hook）
param([switch]$CheckOnly, [switch]$Silent, [string]$AsarPath)
$ErrorActionPreference = "Continue"
$logDir = Join-Path $env:LOCALAPPDATA "pigaibang-hook-toolkit"
$bakDir = Join-Path $logDir "backups"
$log = Join-Path $logDir "hook-toolkit.log"
New-Item -ItemType Directory -Path $logDir,$bakDir -Force | Out-Null
function L($m){ $line = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "  " + $m; Add-Content $log $line -Encoding UTF8; if (-not $Silent) { Write-Host $line } }

$cands = @(
  (Join-Path $env:LOCALAPPDATA "Programs\pigaibang"),
  "C:\Program Files\pigaibang",
  "C:\Program Files (x86)\pigaibang"
)
if ($AsarPath) { $asar = $AsarPath; $dir = Split-Path (Split-Path $asar); $exe = Join-Path $dir "pigaibang.exe" }
else {
  $dir = $cands | Where-Object { Test-Path (Join-Path $_ "resources\app.asar") } | Select-Object -First 1
  if (-not $dir) { L "未找到批改邦安装目录"; exit 1 }
  $asar = Join-Path $dir "resources\app.asar"
  $exe  = Join-Path $dir "pigaibang.exe"
}

$bak = Get-ChildItem $bakDir -Filter "app.asar.*.orig" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $bak -and (Test-Path 'D:\ClassIsland-Backup')) {
  $bak = Get-ChildItem 'D:\ClassIsland-Backup' -Recurse -Filter 'app.asar.orig' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($bak) { L ("使用旧目录备份: " + $bak.FullName) }
}
if (-not $bak) { L "没有可用备份。若批改邦已重装，重装本身即为干净状态"; exit 1 }
L ("使用备份: " + $bak.FullName + " (" + $bak.LastWriteTime + ")")
if ($CheckOnly) { L "检查模式：不修改文件"; exit 0 }

$pg = Get-Process pigaibang -ErrorAction SilentlyContinue
$wasRunning = $null -ne $pg
if ($wasRunning) { $pg | Stop-Process -Force; Start-Sleep -Seconds 4 }
Copy-Item $bak.FullName $asar -Force
L "已还原 app.asar（hook 移除）"
if ($wasRunning -and (Test-Path $exe)) { Start-Process $exe -WorkingDirectory $dir -WindowStyle Minimized; L "批改邦已重启（最小化）" }