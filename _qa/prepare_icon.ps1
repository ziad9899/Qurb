# Upscale the source logo to 1024×1024 PNG for flutter_launcher_icons.
# Source: 561×561 JPG on white background. Target: 1024×1024 PNG with
# high-quality bicubic resampling. Also produce a "foreground" version
# padded ~20% for Android adaptive icons (so the silhouette doesn't get
# cropped by the round/square mask).

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$src = 'C:\Users\MSI\OneDrive\الصور\لوقو قرب5.jpg'
$outDir = 'c:\Users\MSI\OneDrive\Desktop\Minto\assets\icons'
$out  = Join-Path $outDir 'qurb_logo.png'
$outFg = Join-Path $outDir 'qurb_logo_foreground.png'

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory $outDir -Force | Out-Null }

# ---- 1024×1024 full-bleed (iOS app icon source) ----
$srcImg = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap 1024, 1024
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$g.Clear([System.Drawing.Color]::White)
$g.DrawImage($srcImg, 0, 0, 1024, 1024)
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

# ---- 1024×1024 with ~20% padding (Android adaptive foreground) ----
# Android adaptive icons render the foreground inside a 66% safe area
# of the canvas. We pre-pad the silhouette so it survives the mask.
$bmp2 = New-Object System.Drawing.Bitmap 1024, 1024
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g2.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g2.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
# Transparent background so the adaptive background color shows through.
$g2.Clear([System.Drawing.Color]::Transparent)
$pad = 180  # 1024 - 2*180 = 664 → ~65% safe area
$g2.DrawImage($srcImg, $pad, $pad, 1024 - 2*$pad, 1024 - 2*$pad)
$bmp2.Save($outFg, [System.Drawing.Imaging.ImageFormat]::Png)
$g2.Dispose(); $bmp2.Dispose()
$srcImg.Dispose()

Write-Host ("wrote: {0}" -f $out)
Write-Host ("wrote: {0}" -f $outFg)
