# 批改邦 Hook 工具（一键注入 / 一键恢复）

给「批改邦」Electron 客户端的 `app.asar` 注入页面 hook，让它把**教室远程喊话**转发到本地桥接服务（默认 `127.0.0.1:18123`，配合 ClassIsland 插件使用）。

- ✅ **一键注入**：自动备份原版 `app.asar` 再注入
- ✅ **一键恢复**：从最近备份还原，干净移除 hook
- ✅ **静默定时任务**：批改邦每次升级会覆盖 `app.asar`，任务每 30 分钟自检并补回 hook，**全程无窗口、不打扰上课**

## 目录结构

```
一键注入Hook.bat          # 注入 hook（双击运行）
一键恢复.bat              # 还原原始 app.asar（双击运行）
安装静默定时任务.bat      # 注册计划任务：登录时 + 每 30 分钟静默自检
scripts/
  install-hook.ps1        # 注入逻辑（备份 → patch-asar → 替换 → 最小化重启）
  restore.ps1             # 恢复逻辑（选最新备份还原）
  repatch.ps1             # 定时任务调用的自检脚本
  repatch-hidden.vbs      # 用 wscript 零窗口启动 repatch.ps1
assets/
  pgb-hook.js             # 注入到页面上下文的 hook（拦截喊话 WebSocket）
  injection.js            # 追加进 preload 的注入片段
  patch-asar.js           # asar 补丁工具（node）
```

## 使用

**注入**（需要 Node.js 18+）：

```bat
一键注入Hook.bat
:: 静默：一键注入Hook.bat silent
```

脚本会：定位批改邦 → 检查是否已注入 → 备份到 `%LOCALAPPDATA%\pigaibang-hook-toolkit\backups` → 打补丁 → 关掉批改邦 → 替换 `app.asar` → **最小化**重启批改邦。

**恢复**：

```bat
一键恢复.bat
:: 静默：一键恢复.bat silent
```

**安装静默定时任务**：

```bat
安装静默定时任务.bat
```

注册计划任务 `PGB-Hook-AutoRepatch`：登录时 + 每 30 分钟运行一次，通过 `wscript.exe` 以隐藏窗口启动，任务只写日志、不弹窗；若批改邦当时没运行则不会启动它。

## 日志与备份

- 日志：`%LOCALAPPDATA%\pigaibang-hook-toolkit\hook-toolkit.log`
- 备份：`%LOCALAPPDATA%\pigaibang-hook-toolkit\backups\app.asar.<时间戳>.orig`（每次注入前都会备份，保留全部历史）

## 工作原理

1. `patch-asar.js` 解开 `app.asar` 头，找到 `preload` 脚本，在末尾追加：
   ```js
   require("electron").webFrame.executeJavaScript(<pgb-hook.js 内容>)
   ```
2. `pgb-hook.js` 在**页面上下文**里劫持 `WebSocket`，识别批改邦的 `action=announcement` 喊话报文，POST 到本地桥接服务；同时定期发心跳，让桥接端知道页面在线。
3. 还原时直接覆盖回备份的原始 `app.asar`。

## 常见问题

**提示找不到 node.exe**：装 Node.js 或把 node 加入 PATH。
**批改邦升级后 hook 失效**：定时任务会自动补；也可手动跑一次 `一键注入Hook.bat`。
**想彻底卸载**：`一键恢复.bat` 还原，然后在「任务计划程序」删除 `PGB-Hook-AutoRepatch`。
**批改邦装在其他盘**：把路径加到 `scripts\install-hook.ps1` / `restore.ps1` 顶部的 `$cands` 数组里。

## 说明

本工具只修改批改邦本地的 `app.asar`，不修改服务器、不破解授权，仅用于把老师端发起的喊话转发到本机。

## 许可证

MIT

©2026 Starwish1072

## 作者

Starwish1072

Cammile•James（同一人）
