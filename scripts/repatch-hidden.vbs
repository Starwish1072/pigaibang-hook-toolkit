Set fso = CreateObject("Scripting.FileSystemObject")
" 静默调用 scripts\repatch.ps1（不弹任何窗口）
dir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1 = fso.BuildPath(dir, "repatch.ps1")
Set sh = CreateObject("WScript.Shell")
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & ps1 & """"
sh.Run cmd, 0, False
