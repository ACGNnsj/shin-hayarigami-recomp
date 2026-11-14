$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:HAYA_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/haya_xlate.exe'
$env:HAYA_INPUT_FORCE='1'
$env:HAYA_HID_TRACE='1'
$env:HAYA_INPUT_SCRIPT='D:/consoles/tools/nav8.txt'
$env:HAYA_PROFILE_DIR='D:/consoles/tools/shinprofile'
$env:HAYA_PIPELINE_CACHE='D:/consoles/tools/shin-pipeline-cache.bin'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','565' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_T.log -RedirectStandardError D:/consoles/tools/game_T.err
Write-Output ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 65
Add-Type -Namespace W9 -Name TopT -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int h2, uint f);'
$q = Get-Process haya -ErrorAction Stop | Select-Object -First 1
[W9.TopT]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_T1.png"
Start-Sleep -Seconds 235
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_T2.png"
foreach ($i in 3..10) { Start-Sleep -Seconds 30; & D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 ("D:/consoles/tools/select_T{0}.png" -f $i) }
Write-Output 'phaseQ shots done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
