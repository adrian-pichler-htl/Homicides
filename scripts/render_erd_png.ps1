Add-Type -AssemblyName System.Drawing

$width = 1620
$height = 1120
$bmp = New-Object System.Drawing.Bitmap $width, $height
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Colors
$bgColor = [System.Drawing.Color]::FromArgb(248, 249, 250)
$headerBg = [System.Drawing.Color]::FromArgb(235, 232, 249)
$headerBgNew = [System.Drawing.Color]::FromArgb(108, 92, 231)
$borderColor = [System.Drawing.Color]::FromArgb(123, 104, 238)
$borderColorLight = [System.Drawing.Color]::FromArgb(200, 200, 220)
$textColor = [System.Drawing.Color]::FromArgb(45, 52, 54)
$typeColor = [System.Drawing.Color]::FromArgb(120, 120, 140)
$pkColor = [System.Drawing.Color]::FromArgb(214, 48, 49)
$fkColor = [System.Drawing.Color]::FromArgb(9, 132, 227)
$lineColor = [System.Drawing.Color]::FromArgb(108, 92, 231)

$g.Clear($bgColor)

# Fonts
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$fontHeader = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$fontText = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontSmall = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Regular)
$fontSmallBold = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$fontLabel = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)

# Pens & Brushes
$penBorder = New-Object System.Drawing.Pen($borderColor, 1.5)
$penBorderLight = New-Object System.Drawing.Pen($borderColorLight, 1)
$penLine = New-Object System.Drawing.Pen($lineColor, 2)
$penGrid = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 230, 240), 1)

$brushText = New-Object System.Drawing.SolidBrush($textColor)
$brushType = New-Object System.Drawing.SolidBrush($typeColor)
$brushWhite = [System.Drawing.Brushes]::White
$brushZebra = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(248, 249, 250))
$brushLineText = New-Object System.Drawing.SolidBrush($lineColor)

$brushPk = New-Object System.Drawing.SolidBrush($pkColor)
$brushFk = New-Object System.Drawing.SolidBrush($fkColor)

$penGreen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(0, 184, 148), 2)
$brushGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 184, 148))
$brushGreenSoft = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 252, 247))

# Title
$g.DrawString("US Homicides (SHR) - Aktualisiertes Entity-Relationship-Diagramm (ERD)", $fontTitle, $brushText, 60, 25)

# Feedback Box (Top Right)
$fbX = 850
$fbY = 45
$fbW = 710
$fbH = 200

$g.FillRectangle($brushGreenSoft, $fbX, $fbY, $fbW, $fbH)
$g.DrawRectangle($penGreen, $fbX, $fbY, $fbW, $fbH)
$g.FillRectangle($brushGreen, $fbX, $fbY, $fbW, 28)
$g.DrawString("Feedback-Umsetzung & Kriminologische Modellierungsdetails", $fontHeader, $brushWhite, ($fbX + 12), ($fbY + 5))

$g.DrawString("1. Eigene Tabelle fuer After-Update-Trigger (Feedback 3):", $fontBold, $brushText, ($fbX + 15), ($fbY + 38))
$g.DrawString("- Tabelle AUDIT_LOG als eigenstaendige Entitaet hinzugefuegt (protokolliert Situationsaenderungen).", $fontText, $brushText, ($fbX + 30), ($fbY + 56))

$g.DrawString("2. Relationship zu wem? (Feedback 1):", $fontBold, $brushText, ($fbX + 15), ($fbY + 80))
$g.DrawString("- OFFENDER_INVOLVEMENT enthaelt neu 'Victim_Person_ID' als FK auf PERSON (Opfer).", $fontText, $brushText, ($fbX + 30), ($fbY + 98))
$g.DrawString("- Relationship beschreibt die konkrete Beziehung des Taeters zu DIESEM Opfer (z.B. Wife, Friend).", $fontText, $brushText, ($fbX + 30), ($fbY + 116))

$g.DrawString("3. Was ist ungeloest? (Feedback 2):", $fontBold, $brushText, ($fbX + 15), ($fbY + 140))
$g.DrawString("- Ungeloest / Cold Case: Situation IN ('Single/Multiple Victims/Unknown Offender(s)')", $fontText, $brushText, ($fbX + 30), ($fbY + 158))
$g.DrawString("- Kriminologische Definition: Kein Tatverdaechtiger ermittelt (Offender_Count = 0).", $fontText, $brushText, ($fbX + 30), ($fbY + 176))

# Helper to draw a table
function Draw-MyTable($name, $x, $y, $w, $rows, $isNew) {
    $rowH = 24
    $headH = 30
    $totalH = $headH + ($rows.Count * $rowH)
    
    $brushHead = if ($isNew) { New-Object System.Drawing.SolidBrush($headerBgNew) } else { New-Object System.Drawing.SolidBrush($headerBg) }
    $brushHeadText = if ($isNew) { [System.Drawing.Brushes]::White } else { New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(72, 52, 212)) }
    
    # Table box
    $g.FillRectangle([System.Drawing.Brushes]::White, $x, $y, $w, $totalH)
    $g.DrawRectangle($penBorder, $x, $y, $w, $totalH)
    
    # Header
    $g.FillRectangle($brushHead, $x, $y, $w, $headH)
    $g.DrawLine($penBorder, $x, ($y + $headH), ($x + $w), ($y + $headH))
    
    # Title centered
    $rect = New-Object System.Drawing.RectangleF($x, $y, $w, $headH)
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($name, $fontHeader, $brushHeadText, $rect, $sf)
    
    # Columns
    $col1W = 60
    $col3W = 65
    $col2W = $w - $col1W - $col3W
    
    for ($i = 0; $i -lt $rows.Count; $i++) {
        $ry = $y + $headH + ($i * $rowH)
        $r = $rows[$i]
        $type = $r[0]
        $attr = $r[1]
        $key = $r[2]
        
        # Zebra
        if ($i % 2 -eq 1) {
            $g.FillRectangle($brushZebra, $x, $ry, $w, $rowH)
        }
        
        # Grid lines
        $g.DrawLine($penGrid, $x, ($ry + $rowH), ($x + $w), ($ry + $rowH))
        $g.DrawLine($penGrid, ($x + $col1W), $ry, ($x + $col1W), ($ry + $rowH))
        $g.DrawLine($penGrid, ($x + $col1W + $col2W), $ry, ($x + $col1W + $col2W), ($ry + $rowH))
        
        # Text
        $g.DrawString($type, $fontText, $brushType, ($x + 8), ($ry + 3))
        
        $isKey = ($key -like "*PK*") -or ($key -like "*FK*")
        $fText = if ($isKey) { $fontBold } else { $fontText }
        $g.DrawString($attr, $fText, $brushText, ($x + $col1W + 8), ($ry + 3))
        
        $bKey = if ($key -like "*PK*") { $brushPk } elseif ($key -like "*FK*") { $brushFk } else { $brushType }
        $g.DrawString($key, $fontSmallBold, $bKey, ($x + $col1W + $col2W + 8), ($ry + 4))
    }
}

# Tables definition
$tAgency = @(
    @("string", "ORI_Code", "PK"),
    @("string", "Agency_Name", ""),
    @("string", "State_Name", ""),
    @("int", "Population", ""),
    @("string", "County", "")
)

$tIncident = @(
    @("int", "Incident_ID", "PK"),
    @("string", "ORI_Code", "FK"),
    @("int", "Year", ""),
    @("int", "Month", ""),
    @("string", "Incident_Number", ""),
    @("string", "Situation", ""),
    @("string", "Homicide_Type", ""),
    @("int", "Victim_Count", ""),
    @("int", "Offender_Count", ""),
    @("date", "Incident_Date", "")
)

$tAuditLog = @(
    @("int", "Log_ID", "PK"),
    @("int", "Incident_ID", "FK"),
    @("string", "Old_Situation", ""),
    @("string", "New_Situation", ""),
    @("string", "Changed_By", ""),
    @("time", "Changed_At", ""),
    @("string", "Action_Type", "")
)

$tPerson = @(
    @("int", "Person_ID", "PK"),
    @("int", "Age", ""),
    @("char", "Sex", ""),
    @("string", "Race", ""),
    @("string", "Ethnicity", "")
)

$tWeapon = @(
    @("int", "Weapon_ID", "PK"),
    @("string", "Weapon_Code", ""),
    @("string", "Description", "UQ")
)

$tCircumstance = @(
    @("int", "Circumstance_ID", "PK"),
    @("string", "Circumstance_Code", ""),
    @("string", "Description", "UQ")
)

$tVictimInv = @(
    @("int", "Incident_ID", "PK,FK"),
    @("int", "Person_ID", "PK,FK"),
    @("int", "Victim_Sequence", "")
)

$tOffenderInv = @(
    @("int", "Incident_ID", "PK,FK"),
    @("int", "Person_ID", "PK,FK"),
    @("int", "Victim_Person_ID", "FK *"),
    @("int", "Weapon_ID", "FK"),
    @("int", "Circumstance_ID", "FK"),
    @("string", "Relationship", ""),
    @("int", "Offender_Sequence", "")
)

# Draw Tables
Draw-MyTable "AGENCY" 60 70 280 $tAgency $false
Draw-MyTable "INCIDENT" 60 290 280 $tIncident $false
Draw-MyTable "AUDIT_LOG (Trigger)" 60 690 280 $tAuditLog $true
Draw-MyTable "PERSON" 470 290 270 $tPerson $false
Draw-MyTable "VICTIM_INVOLVEMENT" 470 540 270 $tVictimInv $false
Draw-MyTable "WEAPON" 850 290 270 $tWeapon $false
Draw-MyTable "CIRCUMSTANCE" 1220 290 290 $tCircumstance $false
Draw-MyTable "OFFENDER_INVOLVEMENT" 850 540 350 $tOffenderInv $true

# Draw Relationship Lines
function Draw-MyRel($x1, $y1, $x2, $y2, $lbl) {
    $g.DrawLine($penLine, $x1, $y1, $x2, $y2)
    # Circle for 0..n
    $g.FillEllipse([System.Drawing.Brushes]::White, ($x2 - 5), ($y2 - 5), 10, 10)
    $g.DrawEllipse($penLine, ($x2 - 5), ($y2 - 5), 10, 10)
    
    # Label box
    $mx = ($x1 + $x2) / 2
    $my = ($y1 + $y2) / 2
    $size = $g.MeasureString($lbl, $fontLabel)
    $boxX = $mx - ($size.Width / 2) - 4
    $boxY = $my - ($size.Height / 2) - 2
    $boxW = $size.Width + 8
    $boxH = $size.Height + 4
    $g.FillRectangle([System.Drawing.Brushes]::White, $boxX, $boxY, $boxW, $boxH)
    $g.DrawRectangle($penBorderLight, $boxX, $boxY, $boxW, $boxH)
    $g.DrawString($lbl, $fontLabel, $brushLineText, ($mx - ($size.Width / 2)), ($my - ($size.Height / 2)))
}

# AGENCY -> INCIDENT
Draw-MyRel 200 220 200 290 "meldet"
# INCIDENT -> AUDIT_LOG
Draw-MyRel 200 560 200 690 "protokolliert"
# INCIDENT -> VICTIM_INVOLVEMENT
Draw-MyRel 340 420 470 570 "hat Opfer"
# PERSON -> VICTIM_INVOLVEMENT
Draw-MyRel 605 440 605 540 "involviert als Opfer"
# INCIDENT -> OFFENDER_INVOLVEMENT
Draw-MyRel 340 460 850 600 "hat Taeter"
# PERSON -> OFFENDER_INVOLVEMENT (Taeter)
Draw-MyRel 740 370 850 560 "involviert als Taeter"
# PERSON -> OFFENDER_INVOLVEMENT (Bezugsopfer)
Draw-MyRel 740 400 850 590 "Bezugsopfer (*)"
# WEAPON -> OFFENDER_INVOLVEMENT
Draw-MyRel 985 390 985 540 "verwendet bei"
# CIRCUMSTANCE -> OFFENDER_INVOLVEMENT
Draw-MyRel 1300 390 1150 540 "passierte unter"

# Save
$outPath = "C:\Users\adria\OneDrive\Dokumente\Adrian\schule\2627\DBI\Homicides\erd\erd_updated.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output "Successfully rendered ERD to $outPath"
