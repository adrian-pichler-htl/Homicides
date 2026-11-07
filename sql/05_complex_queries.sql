-- ============================================================================
-- DBI Projekt "US Homicides (SHR)" - Teil 2 (SQL & Trigger)
-- Datei: 05_complex_queries.sql
-- Beschreibung: 3 komplexe SQL-Abfragen mit textueller Aufgabenstellung
--               gemäß Projektangabe 2.5.
--
-- Enthaltene Sprachelemente:
-- - JOIN (in allen Abfragen)
-- - GROUP BY (in allen Abfragen)
-- - AVG (in Abfrage 3)
-- - SUM (in Abfrage 1 und 2)
-- - COUNT (in allen Abfragen)
-- - ORDER BY (in allen Abfragen)
-- - Subquery mit IN (in Abfrage 1)
-- - Subquery mit EXISTS (in Abfrage 2)
-- - Subquery mit AVG und vergleichender Filterung (in Abfrage 3)
--
-- ============================================================================

-- ============================================================================
-- ABFRAGE 1: Vergleich der Tötungsdelikte und Gesamtopferzahlen pro Bundesstaat
--            zwischen 1985 und 2025
-- ============================================================================
-- Textuelle Beschreibung:
-- Ermittlung der Entwicklung von Tötungsdelikten und Opferzahlen auf Bundesstaatenebene.
-- Es werden über eine Subquery mit "IN" nur diejenigen Bundesstaaten einbezogen,
-- die in beiden Erhebungsjahren (1985 und 2025) registrierte Fälle vorweisen.
-- Für jeden Staat wird die Gesamtzahl der Vorfälle, die Anzahl der Delikte pro Erhebungsjahr,
-- die aggregierte Opferzahl (SUM) für 1985 und 2025 sowie die absolute und prozentuale
-- Veränderung berechnet.
-- Sortierung: Absteigend nach den Gesamtopferzahlen (ORDER BY).
-- ============================================================================

SELECT 
    a.state_name,
    COUNT(DISTINCT i.incident_id)                                  AS total_incidents,
    SUM(CASE WHEN i.incident_year = 1985 THEN 1 ELSE 0 END)        AS incidents_1985,
    SUM(CASE WHEN i.incident_year = 2025 THEN 1 ELSE 0 END)        AS incidents_2025,
    SUM(CASE WHEN i.incident_year = 1985 THEN i.victim_count ELSE 0 END) AS victims_1985,
    SUM(CASE WHEN i.incident_year = 2025 THEN i.victim_count ELSE 0 END) AS victims_2025,
    (SUM(CASE WHEN i.incident_year = 2025 THEN i.victim_count ELSE 0 END) -
     SUM(CASE WHEN i.incident_year = 1985 THEN i.victim_count ELSE 0 END)) AS victim_change_abs,
    ROUND(
        (SUM(CASE WHEN i.incident_year = 2025 THEN i.victim_count ELSE 0 END) -
         SUM(CASE WHEN i.incident_year = 1985 THEN i.victim_count ELSE 0 END)) * 100.0 /
        NULLIF(SUM(CASE WHEN i.incident_year = 1985 THEN i.victim_count ELSE 0 END), 0), 2
    )                                                              AS victim_change_percent
FROM incident i
JOIN agency a 
    ON i.ori_code = a.ori_code
WHERE a.state_name IN (
    -- Subquery mit IN: Bundesstaaten, die in BEIDEN Erhebungsjahren Fälle aufweisen
    SELECT a1.state_name
    FROM agency a1
    JOIN incident i1 ON a1.ori_code = i1.ori_code
    WHERE i1.incident_year = 1985
    INTERSECT
    SELECT a2.state_name
    FROM agency a2
    JOIN incident i2 ON a2.ori_code = i2.ori_code
    WHERE i2.incident_year = 2025
)
GROUP BY 
    a.state_name
ORDER BY 
    SUM(i.victim_count) DESC;


-- ============================================================================
-- ABFRAGE 2: Die 5 häufigsten Tatwaffen bei Beziehungstaten in Bundesstaaten mit hoher Fallzahl
-- ============================================================================
-- Textuelle Beschreibung:
-- Analyse der am häufigsten eingesetzten Waffenarten bei Beziehungstaten 
-- (z.B. Ehepartner, Partner, Familienangehörige, Bekannte - Ausschluss von 
-- 'Stranger' und 'Unknown Relationship').
-- Die Untersuchung wird über eine Subquery mit "EXISTS" auf solche Bundesstaaten
-- eingeschränkt, die eine signifikant hohe Gesamtzahl an Vorfällen (>= 100) aufweisen.
-- Die Auswertung liefert die Top 5 Waffenarten, die absolute Fallzahl sowie den
-- relativen Anteil an allen Beziehungstaten.
-- Sortierung: Absteigend nach Häufigkeit (ORDER BY), limitiert auf 5 Zeilen.
-- ============================================================================

SELECT 
    w.description                                                  AS weapon_description,
    COUNT(oi.person_id)                                            AS incident_count,
    ROUND(
        COUNT(oi.person_id) * 100.0 / 
        SUM(COUNT(oi.person_id)) OVER(), 2
    )                                                              AS percentage_share
FROM offender_involvement oi
JOIN weapon w 
    ON oi.weapon_id = w.weapon_id
JOIN incident i 
    ON oi.incident_id = i.incident_id
JOIN agency a 
    ON i.ori_code = a.ori_code
WHERE oi.relationship NOT IN ('Stranger', 'Unknown Relationship')
  AND EXISTS (
      -- Subquery mit EXISTS: Nur Bundesstaaten mit hoher Fallzahl (>= 100)
      SELECT 1
      FROM incident sub_i
      JOIN agency sub_a ON sub_i.ori_code = sub_a.ori_code
      WHERE sub_a.state_name = a.state_name
      GROUP BY sub_a.state_name
      HAVING COUNT(sub_i.incident_id) >= 100
  )
GROUP BY 
    w.description
ORDER BY 
    incident_count DESC
FETCH FIRST 5 ROWS ONLY;


-- ============================================================================
-- ABFRAGE 3: Polizeibehörden mit überdurchschnittlich vielen ungelösten Fällen
-- ============================================================================
-- Textuelle Beschreibung:
-- Identifikation aller Polizeibehörden (Agencies), bei denen die Zahl der ungelösten
-- Tötungsdelikte über dem bundesweiten behördlichen Durchschnitt liegt.
--
-- Klärung des Feedbacks ("Was ist ungelöst?"):
-- Als "ungelöst" (unsolved / cold case) werden gemäß den Richtlinien des FBI
-- diejenigen Fälle klassifiziert, bei denen die Täteridentität unbekannt ist
-- (Spalte situation enthält den Begriff 'Unknown Offender', also Situationen
-- 'Single Victim/Unknown Offender(s)' und 'Multiple Victims/Unknown Offender(s)').
--
-- In der HAVING-Klausel wird die Anzahl der ungelösten Fälle der jeweiligen Behörde
-- mit dem Ergebnis einer Subquery verglichen, welche das arithmetische Mittel (AVG)
-- der ungelösten Fälle über alle Behörden berechnet.
-- Weiters wird die ungelöste Fallrate pro 100.000 Einwohner berechnet.
-- Sortierung: Absteigend nach der Anzahl ungelöster Fälle (ORDER BY).
-- ============================================================================

SELECT 
    a.ori_code,
    a.agency_name,
    a.state_name,
    a.population,
    COUNT(i.incident_id)                                           AS unsolved_case_count,
    ROUND(
        COUNT(i.incident_id) * 100000.0 / NULLIF(a.population, 0), 2
    )                                                              AS unsolved_per_100k_pop
FROM agency a
JOIN incident i 
    ON a.ori_code = i.ori_code
WHERE i.situation LIKE '%Unknown Offender%'
GROUP BY 
    a.ori_code,
    a.agency_name,
    a.state_name,
    a.population
HAVING COUNT(i.incident_id) > (
    -- Subquery mit AVG: Bundesweiter behördlicher Durchschnitt ungelöster Fälle
    SELECT AVG(agency_unsolved_count)
    FROM (
        SELECT COUNT(sub_i.incident_id) AS agency_unsolved_count
        FROM incident sub_i
        WHERE sub_i.situation LIKE '%Unknown Offender%'
        GROUP BY sub_i.ori_code
    )
)
ORDER BY 
    unsolved_case_count DESC, 
    a.population DESC;

