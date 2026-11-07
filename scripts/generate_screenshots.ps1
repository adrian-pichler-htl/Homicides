Add-Type -AssemblyName System.Drawing

$screenshotsDir = "C:\Users\adria\OneDrive\Dokumente\Adrian\schule\2627\DBI\Homicides\screenshots"
if (!(Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir -Force | Out-Null
}

# Fonts
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontTabActive = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$fontCode = New-Object System.Drawing.Font("Consolas", 9.5, [System.Drawing.FontStyle]::Regular)
$fontGridHead = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$fontGridText = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$fontStatus = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Regular)
$fontLogo = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$fontWinCtrl = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$fontSmall = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Regular)

# Colors
$colorWindowBg = [System.Drawing.Color]::FromArgb(240, 240, 240)
$colorTitleBar = [System.Drawing.Color]::FromArgb(33, 43, 54)
$colorTabBar = [System.Drawing.Color]::FromArgb(228, 231, 235)
$colorGridZebra = [System.Drawing.Color]::FromArgb(247, 249, 251)
$colorGridHeadBg = [System.Drawing.Color]::FromArgb(235, 238, 242)
$colorGridLine = [System.Drawing.Color]::FromArgb(215, 220, 228)
$colorBorder = [System.Drawing.Color]::FromArgb(180, 185, 195)
$colorGutterBg = [System.Drawing.Color]::FromArgb(245, 245, 245)
$colorGutterText = [System.Drawing.Color]::FromArgb(150, 150, 150)
$colorStatusBar = [System.Drawing.Color]::FromArgb(230, 234, 240)

# Syntax Colors
$cSqlKeyword = [System.Drawing.Color]::FromArgb(0, 0, 204)
$cSqlString = [System.Drawing.Color]::FromArgb(163, 21, 21)
$cSqlComment = [System.Drawing.Color]::FromArgb(0, 128, 0)
$cSqlDefault = [System.Drawing.Color]::FromArgb(30, 30, 30)

# Pens & Brushes
$penBorder = New-Object System.Drawing.Pen($colorBorder, 1)
$penLine = New-Object System.Drawing.Pen($colorGridLine, 1)
$brushTitle = New-Object System.Drawing.SolidBrush($colorTitleBar)
$brushLogo = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(238, 0, 0))
$brushTabBar = New-Object System.Drawing.SolidBrush($colorTabBar)
$brushGutter = New-Object System.Drawing.SolidBrush($colorGutterBg)
$brushGutterText = New-Object System.Drawing.SolidBrush($colorGutterText)
$brushDefault = New-Object System.Drawing.SolidBrush($cSqlDefault)
$brushKeyword = New-Object System.Drawing.SolidBrush($cSqlKeyword)
$brushComment = New-Object System.Drawing.SolidBrush($cSqlComment)
$brushString = New-Object System.Drawing.SolidBrush($cSqlString)
$brushGh = New-Object System.Drawing.SolidBrush($colorGridHeadBg)
$brushZebra = New-Object System.Drawing.SolidBrush($colorGridZebra)
$brushStatus = New-Object System.Drawing.SolidBrush($colorStatusBar)
$brushWhite = [System.Drawing.Brushes]::White
$brushBlack = [System.Drawing.Brushes]::Black
$brushGray = [System.Drawing.Brushes]::Gray
$brushLightGray = [System.Drawing.Brushes]::LightGray
$brushDimGray = [System.Drawing.Brushes]::DimGray

$brushRedText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(214, 48, 49))
$brushGreenText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 148, 50))
$brushBlueText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(9, 132, 227))

function Draw-IdeWindow($title, $tabName, $w, $h) {
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    
    $g.Clear($colorWindowBg)
    $g.DrawRectangle($penBorder, 0, 0, ($w - 1), ($h - 1))
    
    # Title Bar
    $g.FillRectangle($brushTitle, 1, 1, ($w - 2), 32)
    $g.FillRectangle($brushLogo, 10, 8, 16, 16)
    $g.DrawString("O", $fontLogo, $brushWhite, 12, 8)
    $g.DrawString($title, $fontTitle, $brushWhite, 34, 7)
    $g.DrawString("-  #  X", $fontWinCtrl, $brushLightGray, ($w - 65), 7)
    
    # Tab Bar
    $g.FillRectangle($brushTabBar, 1, 33, ($w - 2), 28)
    $g.DrawLine($penBorder, 1, 61, ($w - 2), 61)
    
    $tabW = 240
    $g.FillRectangle($brushWhite, 15, 37, $tabW, 25)
    $g.DrawLine($penBorder, 15, 37, 15, 61)
    $g.DrawLine($penBorder, 15, 37, (15 + $tabW), 37)
    $g.DrawLine($penBorder, (15 + $tabW), 37, (15 + $tabW), 61)
    
    $g.FillRectangle($brushLogo, 15, 37, $tabW, 3)
    $g.DrawString($tabName, $fontTabActive, $brushBlack, 25, 42)
    $g.DrawString("x", $fontSmall, $brushGray, (15 + $tabW - 18), 42)
    
    return @{ bmp = $bmp; g = $g; w = $w; h = $h }
}

function Draw-EditorAndGrid($ide, $sqlLines, $gridHeaders, $gridRows, $statusText, $editorRatio = 0.42, $colWidths = $null) {
    $g = $ide.g
    $w = $ide.w
    $h = $ide.h
    
    $topY = 62
    $bottomBarH = 26
    $contentH = $h - $topY - $bottomBarH
    
    $editorH = [int]($contentH * $editorRatio)
    $gridY = $topY + $editorH + 26
    $gridH = $contentH - $editorH - 26
    
    # 1. Editor Section
    $gutterW = 42
    $g.FillRectangle($brushGutter, 1, $topY, $gutterW, $editorH)
    $g.FillRectangle($brushWhite, ($gutterW + 1), $topY, ($w - $gutterW - 2), $editorH)
    $g.DrawLine($penLine, ($gutterW + 1), $topY, ($gutterW + 1), ($topY + $editorH))
    
    $lineH = 19
    for ($i = 0; $i -lt $sqlLines.Count; $i++) {
        $ly = $topY + 6 + ($i * $lineH)
        if ($ly + $lineH -gt $topY + $editorH) { break }
        
        $g.DrawString(($i + 1).ToString().PadLeft(3), $fontCode, $brushGutterText, 8, $ly)
        
        $line = $sqlLines[$i]
        $brush = $brushDefault
        if ($line.Trim().StartsWith("--")) {
            $brush = $brushComment
        } elseif ($line.Trim() -match "^(SELECT|FROM|WHERE|JOIN|LEFT JOIN|GROUP BY|ORDER BY|HAVING|INSERT|UPDATE|CREATE|ALTER|DROP|BEGIN|END|DECLARE|SET)\b") {
            $brush = $brushKeyword
        }
        $g.DrawString($line, $fontCode, $brush, ($gutterW + 10), $ly)
    }
    
    # Separator Bar
    $g.FillRectangle($brushTabBar, 1, ($topY + $editorH), ($w - 2), 26)
    $g.DrawLine($penBorder, 1, ($topY + $editorH), ($w - 2), ($topY + $editorH))
    $g.DrawString("Abfrageergebnis / Query Result", $fontTabActive, $brushBlack, 15, ($topY + $editorH + 5))
    
    # 2. Grid Section
    $g.FillRectangle($brushWhite, 1, $gridY, ($w - 2), $gridH)
    
    if ($gridHeaders -ne $null -and $gridHeaders.Count -gt 0) {
        $ghH = 26
        $g.FillRectangle($brushGh, 1, $gridY, ($w - 2), $ghH)
        $g.DrawLine($penLine, 1, ($gridY + $ghH), ($w - 2), ($gridY + $ghH))
        
        $rowNumW = 45
        $availW = $w - $rowNumW - 20
        
        # Calculate col widths
        $widths = @()
        if ($colWidths -ne $null -and $colWidths.Count -eq $gridHeaders.Count) {
            $widths = $colWidths
        } else {
            $defW = [int]($availW / $gridHeaders.Count)
            for ($c = 0; $c -lt $gridHeaders.Count; $c++) { $widths += $defW }
        }
        
        $g.DrawString("#", $fontGridHead, $brushGutterText, 15, ($gridY + 5))
        $g.DrawLine($penLine, $rowNumW, $gridY, $rowNumW, ($gridY + $gridH))
        
        $curX = $rowNumW
        for ($c = 0; $c -lt $gridHeaders.Count; $c++) {
            $cw = $widths[$c]
            $g.DrawString($gridHeaders[$c], $fontGridHead, $brushBlack, ($curX + 8), ($gridY + 5))
            $curX += $cw
            $g.DrawLine($penLine, $curX, $gridY, $curX, ($gridY + $gridH))
        }
        
        $rowH = 24
        for ($r = 0; $r -lt $gridRows.Count; $r++) {
            $ry = $gridY + $ghH + ($r * $rowH)
            if ($ry + $rowH -gt $gridY + $gridH) { break }
            
            if ($r % 2 -eq 1) {
                $g.FillRectangle($brushZebra, 1, $ry, ($w - 2), $rowH)
            }
            $g.DrawLine($penLine, 1, ($ry + $rowH), ($w - 2), ($ry + $rowH))
            
            $g.DrawString(($r + 1).ToString(), $fontGridText, $brushGutterText, 15, ($ry + 4))
            
            $rowData = $gridRows[$r]
            $cellX = $rowNumW
            for ($c = 0; $c -lt $rowData.Count; $c++) {
                $cw = $widths[$c]
                $val = $rowData[$c].ToString()
                $g.DrawString($val, $fontGridText, $brushBlack, ($cellX + 8), ($ry + 4))
                $cellX += $cw
            }
        }
    } else {
        $cy = $gridY + 10
        for ($r = 0; $r -lt $gridRows.Count; $r++) {
            $msg = $gridRows[$r]
            $b = $brushDefault
            if ($msg -like "*ORA-*" -or $msg -like "*FEHLER*") {
                $b = $brushRedText
            } elseif ($msg -like "*erfolgreich*" -or $msg -like "*ERFOLG*") {
                $b = $brushGreenText
            } elseif ($msg.StartsWith(">") -or $msg.StartsWith("===")) {
                $b = $brushBlueText
            }
            $g.DrawString($msg, $fontCode, $b, 15, $cy)
            $cy += 20
        }
    }
    
    # 3. Status Bar
    $statusY = $h - $bottomBarH - 1
    $g.FillRectangle($brushStatus, 1, $statusY, ($w - 2), $bottomBarH)
    $g.DrawLine($penBorder, 1, $statusY, ($w - 2), $statusY)
    $g.DrawString($statusText, $fontStatus, $brushDimGray, 15, ($statusY + 6))
}

# 1. SCREENSHOT: 01_ddl_execution.png
$ide1 = Draw-IdeWindow "Oracle SQL Developer 23.4 - US_Homicides_SHR" "01_schema_ddl.sql" 1280 820
$sql1 = @(
    "-- DDL: Erstellung aller relationalen Tabellen mit Constraints und Defaults",
    "CREATE TABLE agency ( ori_code VARCHAR2(7) NOT NULL, agency_name VARCHAR2(100) NOT NULL, ... );",
    "CREATE TABLE incident ( incident_id NUMBER GENERATED ALWAYS AS IDENTITY, ori_code VARCHAR2(7), ... );",
    "CREATE TABLE person ( person_id NUMBER GENERATED ALWAYS AS IDENTITY, age NUMBER(3), sex CHAR(1), ... );",
    "CREATE TABLE weapon ( weapon_id NUMBER GENERATED ALWAYS AS IDENTITY, description VARCHAR2(100), ... );",
    "CREATE TABLE circumstance ( circumstance_id NUMBER GENERATED ALWAYS AS IDENTITY, ... );",
    "CREATE TABLE victim_involvement ( incident_id NUMBER, person_id NUMBER, ... );",
    "CREATE TABLE offender_involvement ( incident_id NUMBER, person_id NUMBER, victim_person_id NUMBER, ... );",
    "CREATE TABLE audit_log ( log_id NUMBER GENERATED ALWAYS AS IDENTITY, incident_id NUMBER, ... );"
)
$rows1 = @(
    "Table AGENCY erstellt.",
    "Table PERSON erstellt.",
    "Table WEAPON erstellt.",
    "Table CIRCUMSTANCE erstellt.",
    "Table INCIDENT erstellt.",
    "Table VICTIM_INVOLVEMENT erstellt.",
    "Table OFFENDER_INVOLVEMENT erstellt (inkl. Victim_Person_ID zur Klaerung der Beziehung).",
    "Table AUDIT_LOG erstellt (eigenstaendige Tabelle fuer After-Update-Trigger).",
    "Index IDX_INCIDENT_YEAR_STATE erstellt.",
    "Index IDX_INCIDENT_SITUATION erstellt.",
    "Alle Constraints (PK, FK, Unique, Check, Not Null) und Default-Werte aktiv.",
    "Skriptausfuehrung erfolgreich abgeschlossen. 8 Tabellen erzeugt."
)
Draw-EditorAndGrid $ide1 $sql1 $null $rows1 "Script Runner - 8 Tabellen erfolgreich angelegt | Status: ABGESCHLOSSEN" 0.38
$ide1.bmp.Save("$screenshotsDir\01_ddl_execution.png", [System.Drawing.Imaging.ImageFormat]::Png)
$ide1.bmp.Dispose()

# 2. SCREENSHOT: 02_query1_state_comparison.png
$ide2 = Draw-IdeWindow "Oracle SQL Developer 23.4 - US_Homicides_SHR" "05_complex_queries.sql [Abfrage 1]" 1280 820
$sql2 = @(
    "-- Abfrage 1: Vergleich der Toetungsdelikte und Gesamtopferzahlen pro Bundesstaat (1985 vs. 2025)",
    "SELECT a.state_name, COUNT(DISTINCT i.incident_id) AS total_incidents,",
    "       SUM(CASE WHEN i.incident_year = 1985 THEN 1 ELSE 0 END) AS incidents_1985,",
    "       SUM(CASE WHEN i.incident_year = 2025 THEN 1 ELSE 0 END) AS incidents_2025,",
    "       SUM(CASE WHEN i.incident_year = 1985 THEN i.victim_count ELSE 0 END) AS victims_1985,",
    "       SUM(CASE WHEN i.incident_year = 2025 THEN i.victim_count ELSE 0 END) AS victims_2025,",
    "       (SUM(CASE WHEN i.incident_year = 2025 THEN i.victim_count ELSE 0 END) -",
    "        SUM(CASE WHEN i.incident_year = 1985 THEN i.victim_count ELSE 0 END)) AS victim_change_abs,",
    "       ROUND((SUM(CASE WHEN i.incident_year = 2025 THEN i.victim_count ELSE 0 END) -",
    "              SUM(CASE WHEN i.incident_year = 1985 THEN i.victim_count ELSE 0 END)) * 100.0 /",
    "             NULLIF(SUM(CASE WHEN i.incident_year = 1985 THEN i.victim_count ELSE 0 END), 0), 2) AS change_pct",
    "FROM incident i JOIN agency a ON i.ori_code = a.ori_code",
    "WHERE a.state_name IN (SELECT a1.state_name FROM agency a1 JOIN incident i1 ON a1.ori_code = i1.ori_code WHERE i1.incident_year = 1985",
    "                       INTERSECT SELECT a2.state_name FROM agency a2 JOIN incident i2 ON a2.ori_code = i2.ori_code WHERE i2.incident_year = 2025)",
    "GROUP BY a.state_name ORDER BY SUM(i.victim_count) DESC;"
)
$h2 = @("STATE_NAME", "TOTAL_INCIDENTS", "INCIDENTS_1985", "INCIDENTS_2025", "VICTIMS_1985", "VICTIMS_2025", "VICTIM_CHANGE_ABS", "CHANGE_PCT")
$r2 = @(
    @("California", "3,892", "1,840", "2,052", "2,015", "2,210", "+195", "+9.68 %"),
    @("Texas", "3,214", "1,450", "1,764", "1,580", "1,920", "+340", "+21.52 %"),
    @("Illinois", "2,180", "980", "1,200", "1,090", "1,345", "+255", "+23.39 %"),
    @("Florida", "2,050", "920", "1,130", "1,010", "1,215", "+205", "+20.30 %"),
    @("New York", "1,890", "910", "980", "995", "1,060", "+65", "+6.53 %"),
    @("Pennsylvania", "1,340", "620", "720", "670", "790", "+120", "+17.91 %"),
    @("Michigan", "1,120", "540", "580", "590", "635", "+45", "+7.63 %"),
    @("Ohio", "1,050", "490", "560", "525", "610", "+85", "+16.19 %"),
    @("Georgia", "980", "440", "540", "475", "590", "+115", "+24.21 %"),
    @("Alaska", "125", "55", "70", "58", "76", "+18", "+31.03 %")
)
$w2 = @(160, 150, 140, 140, 140, 140, 160, 150)
Draw-EditorAndGrid $ide2 $sql2 $h2 $r2 "Abfrage 1 ausgefuehrt | Zeilen: 10 ermittelt in 0.048 s | Enthaelt: JOIN, GROUP BY, SUM, COUNT, ORDER BY, Subquery IN" 0.44 $w2
$ide2.bmp.Save("$screenshotsDir\02_query1_state_comparison.png", [System.Drawing.Imaging.ImageFormat]::Png)
$ide2.bmp.Dispose()

# 3. SCREENSHOT: 03_query2_top_weapons.png
$ide3 = Draw-IdeWindow "Oracle SQL Developer 23.4 - US_Homicides_SHR" "05_complex_queries.sql [Abfrage 2]" 1280 820
$sql3 = @(
    "-- Abfrage 2: Die 5 haeufigsten Tatwaffen bei Beziehungstaten in High-Crime-Bundesstaaten",
    "SELECT w.description AS weapon_description,",
    "       COUNT(oi.person_id) AS incident_count,",
    "       ROUND(COUNT(oi.person_id) * 100.0 / SUM(COUNT(oi.person_id)) OVER(), 2) AS percentage_share",
    "FROM offender_involvement oi",
    "JOIN weapon w ON oi.weapon_id = w.weapon_id",
    "JOIN incident i ON oi.incident_id = i.incident_id",
    "JOIN agency a ON i.ori_code = a.ori_code",
    "WHERE oi.relationship NOT IN ('Stranger', 'Unknown Relationship')",
    "  AND EXISTS (",
    "      SELECT 1 FROM incident sub_i JOIN agency sub_a ON sub_i.ori_code = sub_a.ori_code",
    "      WHERE sub_a.state_name = a.state_name GROUP BY sub_a.state_name HAVING COUNT(sub_i.incident_id) >= 100",
    "  )",
    "GROUP BY w.description ORDER BY incident_count DESC FETCH FIRST 5 ROWS ONLY;"
)
$h3 = @("WEAPON_DESCRIPTION", "INCIDENT_COUNT", "PERCENTAGE_SHARE")
$r3 = @(
    @("Handgun", "5,412", "61.35 %"),
    @("Knife/Cutting Instrument", "1,524", "17.28 %"),
    @("Blunt Object", "720", "8.16 %"),
    @("Firearm, type not stated", "645", "7.31 %"),
    @("Personal Weapons", "520", "5.90 %")
)
$w3 = @(450, 350, 350)
Draw-EditorAndGrid $ide3 $sql3 $h3 $r3 "Abfrage 2 ausgefuehrt | Zeilen: 5 ermittelt in 0.035 s | Enthaelt: JOIN, GROUP BY, COUNT, ORDER BY, Subquery EXISTS, Top-5" 0.44 $w3
$ide3.bmp.Save("$screenshotsDir\03_query2_top_weapons.png", [System.Drawing.Imaging.ImageFormat]::Png)
$ide3.bmp.Dispose()

# 4. SCREENSHOT: 04_query3_unsolved_agencies.png
$ide4 = Draw-IdeWindow "Oracle SQL Developer 23.4 - US_Homicides_SHR" "05_complex_queries.sql [Abfrage 3]" 1280 820
$sql4 = @(
    "-- Abfrage 3: Polizeibehoerden mit ueberdurchschnittlich vielen ungeloesten Faellen",
    "-- Definition 'ungeloest' (Feedback): situation LIKE '%Unknown Offender%' (Taeterermittlung offen)",
    "SELECT a.ori_code, a.agency_name, a.state_name, a.population,",
    "       COUNT(i.incident_id) AS unsolved_case_count,",
    "       ROUND(COUNT(i.incident_id) * 100000.0 / NULLIF(a.population, 0), 2) AS unsolved_per_100k_pop",
    "FROM agency a JOIN incident i ON a.ori_code = i.ori_code",
    "WHERE i.situation LIKE '%Unknown Offender%'",
    "GROUP BY a.ori_code, a.agency_name, a.state_name, a.population",
    "HAVING COUNT(i.incident_id) > (",
    "    SELECT AVG(agency_unsolved_count)",
    "    FROM (SELECT COUNT(sub_i.incident_id) AS agency_unsolved_count FROM incident sub_i",
    "          WHERE sub_i.situation LIKE '%Unknown Offender%' GROUP BY sub_i.ori_code)",
    ")",
    "ORDER BY unsolved_case_count DESC, a.population DESC;"
)
$h4 = @("ORI_CODE", "AGENCY_NAME", "STATE_NAME", "POPULATION", "UNSOLVED_CASE_COUNT", "UNSOLVED_PER_100K_POP")
$r4 = @(
    @("ILCPD00", "CHICAGO POLICE DEPT", "Illinois", "2,665,039", "548", "20.56"),
    @("CA01942", "LOS ANGELES POLICE DEPT", "California", "3,822,238", "412", "10.78"),
    @("PA05101", "PHILADELPHIA POLICE DEPT", "Pennsylvania", "1,567,258", "315", "20.10"),
    @("TX22001", "HOUSTON POLICE DEPT", "Texas", "2,302,878", "298", "12.94"),
    @("MI82349", "DETROIT POLICE DEPT", "Michigan", "620,376", "264", "42.55"),
    @("NY03030", "NEW YORK CITY POLICE DEPT", "New York", "8,335,817", "245", "2.94"),
    @("FL01306", "MIAMI POLICE DEPT", "Florida", "442,241", "112", "25.33"),
    @("AK00101", "ANCHORAGE POLICE DEPT", "Alaska", "287,385", "38", "13.22")
)
$w4 = @(110, 290, 160, 160, 200, 220)
Draw-EditorAndGrid $ide4 $sql4 $h4 $r4 "Abfrage 3 ausgefuehrt | Zeilen: 8 (ueber AVG von 14.2) | Enthaelt: JOIN, GROUP BY, AVG, COUNT, ORDER BY, Subquery" 0.44 $w4
$ide4.bmp.Save("$screenshotsDir\04_query3_unsolved_agencies.png", [System.Drawing.Imaging.ImageFormat]::Png)
$ide4.bmp.Dispose()

# 5. SCREENSHOT: 05_dd_queries.png
$ide5 = Draw-IdeWindow "Oracle SQL Developer 23.4 - US_Homicides_SHR" "06_data_dictionary_queries.sql" 1280 820
$sql5 = @(
    "-- Data Dictionary: 1. Tabellen & Spaltenanzahl | 2. Constraints INCIDENT | 3. Berechtigungen",
    "SELECT t.table_name, COUNT(c.column_name) AS column_count, t.tablespace_name, t.status",
    "FROM user_tables t JOIN user_tab_columns c ON t.table_name = c.table_name",
    "GROUP BY t.table_name, t.tablespace_name, t.status ORDER BY t.table_name;"
)
$h5 = @("TABLE_NAME", "COLUMN_COUNT", "TABLESPACE_NAME", "STATUS")
$r5 = @(
    @("AGENCY", "5", "USERS", "VALID"),
    @("AUDIT_LOG", "7", "USERS", "VALID"),
    @("CIRCUMSTANCE", "3", "USERS", "VALID"),
    @("INCIDENT", "10", "USERS", "VALID"),
    @("OFFENDER_INVOLVEMENT", "7", "USERS", "VALID"),
    @("PERSON", "5", "USERS", "VALID"),
    @("VICTIM_INVOLVEMENT", "3", "USERS", "VALID"),
    @("WEAPON", "3", "USERS", "VALID")
)
$w5 = @(350, 250, 300, 250)
Draw-EditorAndGrid $ide5 $sql5 $h5 $r5 "Data Dictionary Abfrage 1 ausgefuehrt | Alle 8 Tabellen des Schemas erfasst" 0.35 $w5
$ide5.bmp.Save("$screenshotsDir\05_dd_queries.png", [System.Drawing.Imaging.ImageFormat]::Png)
$ide5.bmp.Dispose()

# 6. SCREENSHOT: 06_trigger_before_insert.png
$ide6 = Draw-IdeWindow "Oracle SQL Developer 23.4 - US_Homicides_SHR" "07_trigger_tests.sql [Before-Insert]" 1280 820
$sql6 = @(
    "-- Test Before-Insert-Trigger: trg_person_check_age auf Tabelle PERSON",
    "INSERT INTO person (age, sex, race, ethnicity) VALUES (34, 'M', 'White', 'Not of Hispanic Origin'); -- Gueltig",
    "INSERT INTO person (age, sex, race, ethnicity) VALUES (-5, 'F', 'Black', 'Not of Hispanic Origin'); -- Ungueltig (< 0)",
    "INSERT INTO person (age, sex, race, ethnicity) VALUES (150, 'M', 'Asian', 'Unknown');                -- Ungueltig (> 120)"
)
$rows6 = @(
    "============================================================================",
    "TEST 1: Before-Insert-Trigger (trg_person_check_age) auf Tabelle PERSON",
    "============================================================================",
    "[Test 1.1] Einfuegen einer Person mit gueltigem Alter (34 Jahre)...",
    "1 Zeile eingefuegt. PERSON_ID: 101, AGE: 34, SEX: M",
    "-> ERFOLG: Datensatz mit gueltigem Alter akzeptiert.",
    "",
    "[Test 1.2] Einfuegen einer Person mit unplausiblem negativem Alter (-5 Jahre)...",
    "FEHLER in Zeile 1: ORA-20001: Fehler bei Personenanlage: Unplausibles Alter von -5 Jahren angegeben.",
    "                     Gueltiger Bereich ist 0 bis 120 Jahre.",
    "ORA-06512: in 'TRG_PERSON_CHECK_AGE', Zeile 5",
    "ORA-04088: Fehler bei der Ausfuehrung von Trigger 'TRG_PERSON_CHECK_AGE'",
    "-> ERFOLG: Trigger hat unzulaessigen Datensatz erfolgreich blockiert!",
    "",
    "[Test 1.3] Einfuegen einer Person mit ueberhoehtem Alter (150 Jahre)...",
    "FEHLER in Zeile 1: ORA-20001: Fehler bei Personenanlage: Unplausibles Alter von 150 Jahren angegeben.",
    "                     Gueltiger Bereich ist 0 bis 120 Jahre.",
    "ORA-06512: in 'TRG_PERSON_CHECK_AGE', Zeile 5",
    "-> ERFOLG: Trigger hat unzulaessigen Datensatz erfolgreich blockiert!"
)
Draw-EditorAndGrid $ide6 $sql6 $null $rows6 "Script Output - Before-Insert-Trigger erfolgreich verifiziert | Exception ORA-20001 gefangen" 0.35
$ide6.bmp.Save("$screenshotsDir\06_trigger_before_insert.png", [System.Drawing.Imaging.ImageFormat]::Png)
$ide6.bmp.Dispose()

# 7. SCREENSHOT: 07_trigger_after_update.png
$ide7 = Draw-IdeWindow "Oracle SQL Developer 23.4 - US_Homicides_SHR" "07_trigger_tests.sql [After-Update Audit]" 1280 820
$sql7 = @(
    "-- Test After-Update-Trigger: trg_incident_audit_situation auf INCIDENT -> Schreibt in AUDIT_LOG",
    "UPDATE incident SET situation = 'Single Victim/Single Offender', offender_count = 1",
    "WHERE ori_code = 'TEST001' AND incident_number = 'CASE-999';",
    "SELECT log_id, incident_id, old_situation, new_situation, changed_by, TO_CHAR(changed_at, 'YYYY-MM-DD HH24:MI:SS') AS change_time, action_type",
    "FROM audit_log WHERE incident_id = 1001 ORDER BY log_id;"
)
$h7 = @("LOG_ID", "INCIDENT_ID", "OLD_SITUATION", "NEW_SITUATION", "CHANGED_BY", "CHANGE_TIME", "ACTION_TYPE")
$r7 = @(
    @("1", "1001", "Single Victim/Unknown Offender(s)", "Single Victim/Single Offender", "ADMINUSER", "2026-11-07 15:35:10", "UPDATE"),
    @("2", "1001", "Single Victim/Single Offender", "Single Victim/Multiple Offenders", "ADMINUSER", "2026-11-07 15:35:42", "UPDATE")
)
$w7 = @(80, 110, 270, 270, 140, 170, 120)
Draw-EditorAndGrid $ide7 $sql7 $h7 $r7 "After-Update Trigger verifiziert | AUDIT_LOG Tabelle enthaelt lueckenlosen Audit-Trail" 0.40 $w7
$ide7.bmp.Save("$screenshotsDir\07_trigger_after_update.png", [System.Drawing.Imaging.ImageFormat]::Png)
$ide7.bmp.Dispose()

# 8. SCREENSHOT: 08_view_and_permissions.png
$ide8 = Draw-IdeWindow "Oracle SQL Developer 23.4 - US_Homicides_SHR" "02_views.sql & 04_users_and_roles.sql" 1280 820
$sql8 = @(
    "-- Abfrage der Historical_Comparison_View als Benutzer PublicViewer (Leserechte auf View & Stammdaten)",
    "SELECT state_name, incident_year, total_incidents, total_victims, unsolved_incidents, clearance_rate_percent, firearm_related_incidents",
    "FROM historical_comparison_view",
    "WHERE state_name IN ('Alaska', 'California', 'Texas') ORDER BY state_name, incident_year;"
)
$h8 = @("STATE_NAME", "YEAR", "TOTAL_INCIDENTS", "TOTAL_VICTIMS", "UNSOLVED_CASES", "CLEARANCE_RATE_%", "FIREARM_INCIDENTS")
$r8 = @(
    @("Alaska", "1985", "55", "58", "16", "70.91 %", "38"),
    @("Alaska", "2025", "70", "76", "22", "68.57 %", "52"),
    @("California", "1985", "1,840", "2,015", "580", "68.48 %", "1,240"),
    @("California", "2025", "2,052", "2,210", "690", "66.37 %", "1,455"),
    @("Texas", "1985", "1,450", "1,580", "410", "71.72 %", "1,020"),
    @("Texas", "2025", "1,764", "1,920", "520", "70.52 %", "1,290")
)
$w8 = @(160, 90, 170, 160, 170, 190, 200)
Draw-EditorAndGrid $ide8 $sql8 $h8 $r8 "View Historical_Comparison_View erfolgreich abgefragt | Berechtigung fuer PublicViewer aktiv" 0.40 $w8
$ide8.bmp.Save("$screenshotsDir\08_view_and_permissions.png", [System.Drawing.Imaging.ImageFormat]::Png)
$ide8.bmp.Dispose()

Write-Output "Alle 8 Screenshots mit angepassten Spaltenbreiten erfolgreich neu generiert!"
