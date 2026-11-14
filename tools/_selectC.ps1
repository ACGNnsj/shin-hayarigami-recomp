$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:XC2_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/xc2_xlate.exe'
$env:XC2_INPUT_FORCE='1'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','200' -PassThru -NoNewWindow
Write-Output ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 60
Add-Type -Namespace W9 -Name TopC -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int hh, uint f);'
$q = Get-Process haya -ErrorAction Stop | Select-Object -First 1
[W9.TopC]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_C0.png"
Add-Type -Namespace W -Name KBC -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, System.UIntPtr dwExtraInfo);'
function Tap([int]$vk){ [W.KBC]::keybd_event([byte]$vk,0,0,[System.UIntPtr]::Zero); Start-Sleep -Milliseconds 200; [W.KBC]::keybd_event([byte]$vk,0,2,[System.UIntPtr]::Zero); Start-Sleep -Milliseconds 600 }
Tap 0x45; Write-Output 'tapped E1'
Start-Sleep -Seconds 8
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_C1.png"
Tap 0x45; Write-Output 'tapped E2'
Start-Sleep -Seconds 8
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_C2.png"
Write-Output 'phaseC done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
