$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:HAYA_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/haya_xlate.exe'
$env:HAYA_INPUT_FORCE='1'
$env:HAYA_HID_TRACE='1'
$env:HAYA_INPUT_SCRIPT='D:/consoles/tools/nav1.txt'
$env:HAYA_PIPELINE_CACHE='D:/consoles/tools/shin-pipeline-cache.bin'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','300' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_M.log -RedirectStandardError D:/consoles/tools/game_M.err
Write-Output ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 65
Add-Type -Namespace W9 -Name TopM -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int h2, uint f);'
$q = Get-Process haya -ErrorAction Stop | Select-Object -First 1
[W9.TopM]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_M1.png"
Start-Sleep -Seconds 30
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_M2.png"
Start-Sleep -Seconds 65
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_M3.png"
Start-Sleep -Seconds 50
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_M4.png"
Start-Sleep -Seconds 50
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_M5.png"
Write-Output 'phaseM shots done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
