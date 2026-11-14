$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:XC2_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/xc2_xlate.exe'
$env:XC2_INPUT_FORCE='1'
$env:XC2_HID_TRACE='1'
$env:XC2_INPUT_SCRIPT='D:/consoles/tools/nav9.txt'
$env:XC2_PROFILE_DIR='D:/consoles/tools/shinprofile'
$env:XC2_PIPELINE_CACHE='D:/consoles/tools/shin-pipeline-cache.bin'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','565' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_V.log -RedirectStandardError D:/consoles/tools/game_V.err
Write-Output ("game pid={0}" -f $p.Id)
Add-Type -Namespace W9 -Name TopV -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int h2, uint f);'
function Snap([string]$f){ $q = Get-Process haya -ErrorAction SilentlyContinue | Select-Object -First 1; if ($q -and $q.MainWindowHandle -ne 0) { [W9.TopV]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null; Start-Sleep -Milliseconds 400 }; & D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 $f }
Start-Sleep -Seconds 65; Snap "D:/consoles/tools/select_V1.png"
Start-Sleep -Seconds 235; Snap "D:/consoles/tools/select_V2.png"
Start-Sleep -Seconds 60; Snap "D:/consoles/tools/select_V3.png"
Start-Sleep -Seconds 60; Snap "D:/consoles/tools/select_V4.png"
Start-Sleep -Seconds 40; Snap "D:/consoles/tools/select_V5.png"
foreach ($i in 6..13) { Start-Sleep -Seconds 10; Snap ("D:/consoles/tools/select_V{0}.png" -f $i) }
Write-Output 'phaseV shots done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
