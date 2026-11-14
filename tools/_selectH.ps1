$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:XC2_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/xc2_xlate.exe'
$env:XC2_INPUT_FORCE='1'
$env:XC2_HID_TRACE='1'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','260' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_H.log -RedirectStandardError D:/consoles/tools/game_H.err
Write-Output ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 65
Add-Type -Namespace W9 -Name TopH -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int hh, uint f); [DllImport("user32.dll")] public static extern bool SetForegroundWindow(System.IntPtr h);'
$q = Get-Process haya -ErrorAction Stop | Select-Object -First 1
[W9.TopH]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null
[W9.TopH]::SetForegroundWindow($q.MainWindowHandle) | Out-Null
Add-Type -Namespace W -Name KBH -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, System.UIntPtr dwExtraInfo);'
function Tap([int]$vk){ [W.KBH]::keybd_event([byte]$vk,0,0,[System.UIntPtr]::Zero); Start-Sleep -Milliseconds 300; [W.KBH]::keybd_event([byte]$vk,0,2,[System.UIntPtr]::Zero); Start-Sleep -Milliseconds 500 }
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_H0.png"
Tap 0x45; Write-Output 'tapped E1'
Start-Sleep -Seconds 8
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_H1.png"
Tap 0x45; Write-Output 'tapped E2'
Start-Sleep -Seconds 5
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_H2.png"
Start-Sleep -Seconds 40
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_H3.png"
Tap 0x45; Write-Output 'tapped E3'
Start-Sleep -Seconds 10
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_H4.png"
Write-Output 'phaseH done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
