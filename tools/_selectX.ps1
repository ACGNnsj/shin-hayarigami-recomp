$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:HAYA_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/haya_xlate.exe'
$env:HAYA_INPUT_FORCE='1'
$env:HAYA_HID_TRACE='1'
$env:HAYA_INPUT_SCRIPT='D:/consoles/tools/nav12.txt'
$env:HAYA_PROFILE_DIR='D:/consoles/tools/shinprofile'
$env:HAYA_PIPELINE_CACHE='D:/consoles/tools/shin-pipeline-cache.bin'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','565' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_X.log -RedirectStandardError D:/consoles/tools/game_X.err
Write-Output ("game pid={0}" -f $p.Id)
Add-Type -Namespace W9 -Name TopX -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int h2, uint f);'
function Snap([string]$f){ $q = Get-Process haya -ErrorAction SilentlyContinue | Select-Object -First 1; if ($q -and $q.MainWindowHandle -ne 0) { [W9.TopX]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 60, 40, 1280, 800, 0x0040) | Out-Null; Start-Sleep -Milliseconds 500 }; & D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 $f }
Start-Sleep -Seconds 65; Snap "D:/consoles/tools/select_X1.png"
Start-Sleep -Seconds 235; Snap "D:/consoles/tools/select_X2.png"
Start-Sleep -Seconds 60; Snap "D:/consoles/tools/select_X3.png"
Start-Sleep -Seconds 60; Snap "D:/consoles/tools/select_X4.png"
Start-Sleep -Seconds 40; Snap "D:/consoles/tools/select_X5.png"
foreach ($i in 6..14) { Start-Sleep -Seconds 10; Snap ("D:/consoles/tools/select_X{0}.png" -f $i) }
Write-Output 'phaseW shots done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
