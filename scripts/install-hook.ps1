# 一键注入 Hook：把页面 hook 注入批改邦 app.asar（注入前自动备份）
param([switch]$CheckOnly, [switch]$Silent, [string]$AsarPath)
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $root "assets"
$logDir = Join-Path $env:LOCALAPPDATA "pigaibang-hook-toolkit"
$bakDir = Join-Path $logDir "backups"
$log = Join-Path $logDir "hook-toolkit.log"
New-Item -ItemType Directory -Path $logDir,$bakDir -Force | Out-Null
function L($m){ $line = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "  " + $m; Add-Content $log $line -Encoding UTF8; if (-not $Silent) { Write-Host $line } }

# 1. 定位批改邦
$cands = @(
  (Join-Path $env:LOCALAPPDATA "Programs\pigaibang"),
  "C:\Program Files\pigaibang",
  "C:\Program Files (x86)\pigaibang"
)
if ($AsarPath) { $asarOverride = $AsarPath } else { $dir = $cands | Where-Object { Test-Path (Join-Path $_ "resources\app.asar") } | Select-Object -First 1 }
if ($asarOverride) { $asar = $asarOverride; $dir = Split-Path (Split-Path $asar); $exe = Join-Path $dir "pigaibang.exe" }
else {
  if (-not $dir) { L "未找到批改邦安装目录"; exit 1 }
  $asar = Join-Path $dir "resources\app.asar"
  $exe  = Join-Path $dir "pigaibang.exe"
}
L ("批改邦目录: " + $dir)

# 2. 是否已注入
$bytes = [IO.File]::ReadAllBytes($asar)
$txt = [Text.Encoding]::UTF8.GetString($bytes)
if ($txt.Contains("PGB Shout Bridge injection")) { L "已注入，无需操作"; exit 0 }
L "检测到未注入（或升级后失效）"
if ($CheckOnly) { L "检查模式：不修改文件"; exit 0 }

# 3. 找 node
$node = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $node) { foreach($p in @("C:\Program Files\nodejs\node.exe","C:\Program Files (x86)\nodejs\node.exe")) { if (Test-Path $p) { $node = $p } } }
if (-not $node) { L "未找到 node.exe，请先安装 Node.js"; exit 1 }

# 4. 备份 + 打补丁
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$bak = Join-Path $bakDir ("app.asar." + $stamp + ".orig")
Copy-Item $asar $bak -Force
L ("已备份: " + $bak)

$tmp = Join-Path $env:TEMP ("pgb-" + $stamp + ".bin")
$outp = Join-Path $env:TEMP ("pgb-" + $stamp + ".patched.asar")
Copy-Item $asar $tmp -Force
& $node (Join-Path $assets "patch-asar.js") $tmp $outp (Join-Path $assets "injection.js") | Out-Null
if (-not (Test-Path $outp)) { L "补丁失败：未生成输出文件"; exit 1 }

# 5. 关批改邦 -> 替换 -> 重启（最小化）
$pg = Get-Process pigaibang -ErrorAction SilentlyContinue
$wasRunning = $null -ne $pg
if ($wasRunning) { $pg | Stop-Process -Force; Start-Sleep -Seconds 4 }
Copy-Item $outp $asar -Force
Remove-Item $tmp,$outp -Force -ErrorAction SilentlyContinue
Remove-Item Env:ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue
if ($wasRunning -and (Test-Path $exe)) { Start-Process $exe -WorkingDirectory $dir -WindowStyle Minimized; L "已注入并重启批改邦（最小化）" } else { L "已注入（批改邦未运行，下次打开生效）" }
L "完成：打开批改邦远程喊话页即可连上 ClassIsland"