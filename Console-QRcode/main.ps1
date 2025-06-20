
<# ======================== COLSOLE QR CODE GENERATOR ==================================
 
SYNOPSIS
Use 'chart.googleapis.com' to create a qrcode then represent the qrcode in the console!

USAGE
1. Run script
2. Enter text or url to generate
3. Choose invert colors or not
4. Check console for results
#>
$URL = "$txt"
$highC = 'y'
$inverse = 'n'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Console]::BackgroundColor = "Black"

cls

function Generate-QRCodeURL {
    param ([string]$URL,[int]$sizePercentage = 50)
    $EncodedURL = [uri]::EscapeDataString($URL)
    $newSize = [math]::Round((300 * $sizePercentage) / 100)
    # New working QR code API
    $QRCodeURL = "https://api.qrserver.com/v1/create-qr-code/?size=${newSize}x${newSize}&data=$EncodedURL"
    return $QRCodeURL
}

function Download-QRCodeImage {
    param ([string]$QRCodeURL)
    $TempFile = [System.IO.Path]::GetTempFileName() + ".png"
    Invoke-WebRequest -Uri $QRCodeURL -OutFile $TempFile
    return $TempFile
}

$QRCodeURL = Generate-QRCodeURL -URL $URL
$QRCodeImageFile = Download-QRCodeImage -QRCodeURL $QRCodeURL
$QRCodeImage = [System.Drawing.Image]::FromFile($QRCodeImageFile)
$Bitmap = New-Object System.Drawing.Bitmap($QRCodeImage)

# Characters for different contrast and inverse modes
if (($highC -eq 'n') -and ($inverse -eq 'y')){
    $Chars = @('░', '█')
}
elseif (($highC -eq 'n') -and ($inverse -eq 'n')){
    $Chars = @('█', '░')
}
elseif (($highC -eq 'y') -and ($inverse -eq 'y')){
    $Chars = @(' ', '█')
}
elseif (($highC -eq 'y') -and ($inverse -eq 'n')){
    $Chars = @('█', ' ')
}

# Render QR code as characters
for ($y = 0; $y -lt $Bitmap.Height; $y += 2) {
    for ($x = 0; $x -lt $Bitmap.Width; $x++) {
        $pixel = $Bitmap.GetPixel($x, $y)
        $Index = if ($pixel.R -lt 128 -and $pixel.G -lt 128 -and $pixel.B -lt 128) { 1 } else { 0 }
        Write-Host -NoNewline $Chars[$Index]
    }
    Write-Host
}

$QRCodeImage.Dispose()
Remove-Item -Path $QRCodeImageFile -Force
pause
