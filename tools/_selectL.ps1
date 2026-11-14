$ErrorActionPreference='Stop'
$env:PATH='C:\msys64\ucrt64\bin;'+$env:PATH
$env:XC2_XLATE='D:/consoles/ns/shin-hayarigami-recomp/build/xlate/xc2_xlate.exe'
$env:XC2_INPUT_FORCE='1'
$env:XC2_HID_TRACE='1'
$dir='D:/consoles/ns/shin-hayarigami-recomp'
Set-Location $dir
Get-Process haya -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
$p = Start-Process -FilePath "$dir/build/v0/haya.exe" -ArgumentList '--seconds','300' -PassThru -NoNewWindow -RedirectStandardOutput D:/consoles/tools/game_L.log -RedirectStandardError D:/consoles/tools/game_L.err
Write-Output ("game pid={0}" -f $p.Id)
Start-Sleep -Seconds 60
Add-Type -Namespace W9 -Name TopL -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetWindowPos(System.IntPtr h, System.IntPtr a, int x, int y, int w, int hh, uint f); [DllImport("user32.dll")] public static extern bool SetForegroundWindow(System.IntPtr h); [DllImport("user32.dll")] public static extern System.IntPtr GetForegroundWindow();'
Add-Type -Namespace W -Name KBL -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, System.UIntPtr dwExtraInfo);'
function BtnCount(){ $f='D:/consoles/tools/game_L.err'; if (Test-Path $f) { return @(Select-String -Path $f -Pattern 'buttons 0x' -SimpleMatch).Count } else { return 0 } }
function HoldChecked([int]$vk,[string]$tag){
  for ($i=1; $i -le 4; $i++) {
    $q = Get-Process haya -ErrorAction Stop | Select-Object -First 1
    [W9.TopL]::SetWindowPos($q.MainWindowHandle, [System.IntPtr](-1), 0, 0, 0, 0, 0x43) | Out-Null
    [W9.TopL]::SetForegroundWindow($q.MainWindowHandle) | Out-Null
    $fg = [W9.TopL]::GetForegroundWindow()
    $before = BtnCount
    [W.KBL]::keybd_event([byte]$vk,0,0,[System.UIntPtr]::Zero); Start-Sleep -Seconds 2; [W.KBL]::keybd_event([byte]$vk,0,2,[System.UIntPtr]::Zero)
    Start-Sleep -Seconds 2
    $after = BtnCount
    Write-Output ("{0} try{1}: fg={2} game={3} btns {4}->{5}" -f $tag,$i,$fg,$q.MainWindowHandle,$before,$after)
    if ($after -gt $before) { return $true }
    Start-Sleep -Seconds 5
  }
  return $false
}
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_L0.png"
$r1 = HoldChecked 0x45 'E1'
Write-Output ("E1 delivered={0}" -f $r1)
Start-Sleep -Seconds 8
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_L1.png"
$r2 = HoldChecked 0x45 'E2'
Write-Output ("E2 delivered={0}" -f $r2)
Start-Sleep -Seconds 40
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_L2.png"
Start-Sleep -Seconds 40
& D:/consoles/ns/hayarigami-recomp/tools/_shot_screen.ps1 "D:/consoles/tools/select_L3.png"
Write-Output 'phaseL shots done, waiting exit'
$p.WaitForExit()
Write-Output ("exit={0}" -f $p.ExitCode)
