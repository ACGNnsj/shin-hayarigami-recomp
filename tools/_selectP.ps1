$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:XC2_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/xc2_xlate.exe'
$env:XC2_INPUT_FORCE='1'
$env:XC2_HID_TRACE='1'
$env:XC2_INPUT_SCRIPT='D:/consoles/tools/nav5.txt'
$env:XC2_PROFILE_DIR='D:/consoles/tools/shinprofile'
$env:XC2_PIPELINE_CACHE='D:/consoles/tools/shin-pipeline-cache.bin'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','/--seconds.' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_Q.log -RedirectStandardError D:/consoles/tools/game_Q.err
Write-Output ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 65
Add-Type -Namespace W9 -Name TopP -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int h2, uint f);'
$q = Get-Process haya -ErrorAction Stop | Select-Object -First 1
[W9.TopP]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_P1.png"
Start-Sleep -Seconds 285
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_P2.png"
Start-Sleep -Seconds 70
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_P3.png"
Start-Sleep -Seconds 70
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_P4.png"
Start-Sleep -Seconds 60
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_P5.png"
Write-Output 'phaseP shots done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
