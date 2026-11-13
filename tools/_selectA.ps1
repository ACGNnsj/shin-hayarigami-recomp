$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:XC2_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/xc2_xlate.exe'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','180' -PassThru -NoNewWindow
Write-Output ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 60
& D:/consoles/ns/hayarigami-recomp/tools/_foreground.ps1
Add-Type -Namespace W9 -Name Top -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int hh, uint f);'
$q = Get-Process haya -ErrorAction Stop | Select-Object -First 1
[W9.Top]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null
& D:/consoles/tools/_fg_verify.ps1
Start-Sleep 1
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_A.png"
Write-Output "phaseA done"
