$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:HAYA_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/haya_xlate.exe'
$env:HAYA_PROFILE_DIR='D:/consoles/tools/shinprofile'
$env:HAYA_PIPELINE_CACHE='D:/consoles/tools/shin-pipeline-cache.bin'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','110' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_Z.log -RedirectStandardError D:/consoles/tools/game_Z.err
Write-Output ("game pid={0}" -f $p.Id)
Add-Type -Namespace W9 -Name TopZ -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int h2, uint f);'
Start-Sleep -Seconds 65
$q = Get-Process haya -ErrorAction SilentlyContinue | Select-Object -First 1
if ($q -and $q.MainWindowHandle -ne 0) { [W9.TopZ]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 60, 40, 1280, 800, 0x0040) | Out-Null; Start-Sleep -Milliseconds 500 }
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_Z1.png"
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
