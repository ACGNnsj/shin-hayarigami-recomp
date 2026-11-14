$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:XC2_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/xc2_xlate.exe'
$env:XC2_INPUT_FORCE='1'
$env:XC2_HID_TRACE='1'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','300' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_K.log -RedirectStandardError D:/consoles/tools/game_K.err
Write-Output ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 65
Add-Type -Namespace W9 -Name TopK -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int hh, uint f); [DllImport("user32.dll")] public static extern bool SetForegroundWindow(System.IntPtr h);'
$q = Get-Process haya -ErrorAction Stop | Select-Object -First 1
[W9.TopK]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null
[W9.TopK]::SetForegroundWindow($q.MainWindowHandle) | Out-Null
Add-Type -Namespace W -Name KBK -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, System.UIntPtr dwExtraInfo);'
function Hold([int]$vk,[int]$sec){ [W.KBK]::keybd_event([byte]$vk,0,0,[System.UIntPtr]::Zero); Start-Sleep -Seconds $sec; [W.KBK]::keybd_event([byte]$vk,0,2,[System.UIntPtr]::Zero); Start-Sleep -Milliseconds 500 }
Hold 0x45 2; Write-Output 'held E1'
Start-Sleep -Seconds 8
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_J1.png"
Hold 0x45 2; Write-Output 'held E2'
Start-Sleep -Seconds 40
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_J2.png"
Start-Sleep -Seconds 40
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_J3.png"
Start-Sleep -Seconds 40
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_J4.png"
Write-Output 'phaseJ shots done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
