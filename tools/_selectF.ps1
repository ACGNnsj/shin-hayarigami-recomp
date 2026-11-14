$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:HAYA_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/haya_xlate.exe'
$env:HAYA_INPUT_FORCE='1'
$env:HAYA_HID_TRACE='1'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','200' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_F.log -RedirectStandardError D:/consoles/tools/game_F.err
Write-Output ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 60
Add-Type -Namespace W9 -Name TopF -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int hh, uint f); [DllImport("user32.dll")] public static extern bool SetForegroundWindow(System.IntPtr h);'
$q = Get-Process haya -ErrorAction Stop | Select-Object -First 1
[W9.TopF]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null
Start-Sleep 1
[W9.TopF]::SetForegroundWindow($q.MainWindowHandle) | Out-Null
Write-Output 'foregrounded'
Add-Type -Namespace W -Name KBF -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, System.UIntPtr dwExtraInfo);'
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_F0.png"
[W.KBF]::keybd_event(0x45,0,0,[System.UIntPtr]::Zero)
Write-Output 'E down (hold 6s)'
Start-Sleep -Seconds 6
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_F1.png"
[W.KBF]::keybd_event(0x45,0,2,[System.UIntPtr]::Zero)
Write-Output 'E up'
Start-Sleep -Seconds 3
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_F2.png"
Write-Output 'phaseF done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
