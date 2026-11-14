$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:XC2_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/xc2_xlate.exe'
$env:XC2_INPUT_FORCE='1'
$env:XC2_HID_TRACE='1'
$env:XC2_INPUT_SCRIPT='D:/consoles/tools/nav2.txt'
$env:XC2_PROFILE_DIR='D:/consoles/tools/shinprofile'
$env:XC2_PIPELINE_CACHE='D:/consoles/tools/shin-pipeline-cache.bin'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','320' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_N.log -RedirectStandardError D:/consoles/tools/game_N.err
Write-Output ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 65
Add-Type -Namespace W9 -Name TopN -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int h2, uint f);'
$q = Get-Process haya -ErrorAction Stop | Select-Object -First 1
[W9.TopN]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_N1.png"
Start-Sleep -Seconds 35
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_N2.png"
Start-Sleep -Seconds 65
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_N3.png"
Start-Sleep -Seconds 60
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_N4.png"
Start-Sleep -Seconds 50
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_N5.png"
Write-Output 'phaseN shots done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
