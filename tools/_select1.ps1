$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:HAYA_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/haya_xlate.exe'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','120','--shot',"$dir/build/v0/select_game1.png" -PassThru -NoNewWindow
Write-Host ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 60
& D:/consoles/ns/hayarigami-recomp/tools/_foreground.ps1
& D:/consoles/tools/_fg_verify.ps1
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_before.png"
Add-Type -Namespace W -Name K -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, System.UIntPtr dwExtraInfo);'
[W.K]::keybd_event([byte]0x45, 0, 0, [System.UIntPtr]::Zero)
Start-Sleep -Milliseconds 150
[W.K]::keybd_event([byte]0x45, 0, 2, [System.UIntPtr]::Zero)
Write-Host "tapped E(0x45)"
Start-Sleep -Seconds 12
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_after.png"
$p.WaitForExit()
Write-Host ("exit={0}" -f $p.ExitCode)
Get-Content "$dir/build/v0/select_game1.log.err" -Tail 15
