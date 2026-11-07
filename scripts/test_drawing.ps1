Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap 100, 100
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::White)
$brush = [System.Drawing.Brushes]::Black
$font = New-Object System.Drawing.Font("Arial", 12)
$g.DrawString("Test", $font, $brush, 10, 10)
$bmp.Save("test_out.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output "File created: $(Test-Path 'test_out.png')"
Remove-Item "test_out.png"

