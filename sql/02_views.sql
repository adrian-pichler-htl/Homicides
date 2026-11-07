-- ============================================================================
-- DBI Projekt "US Homicides (SHR)" - Teil 2 (SQL & Trigger)
-- Datei: 02_views.sql
-- Beschreibung: Erstellung der View Historical_Comparison_View gemäß Exposé
--               und Projektangabe 2.7.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View: HISTORICAL_COMPARISON_VIEW
-- Verknüpft Vorfälle (INCIDENT), Meldebehörden (AGENCY), Tatbeteiligungen
-- (OFFENDER_INVOLVEMENT) und Waffen (WEAPON) über JOINs.
-- Berechnet aggregierte Kennzahlen (Fallzahlen, Opferzahlen, Aufklärungsrate,
-- Schusswaffenanteil) im direkten Vergleich zwischen den Erhebungsjahren.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW historical_comparison_view AS
SELECT 
    a.state_name,
    i.incident_year,
    COUNT(DISTINCT i.incident_id)                                  AS total_incidents,
    SUM(i.victim_count)                                            AS total_victims,
    SUM(CASE WHEN i.situation LIKE '%Unknown%' THEN 1 ELSE 0 END)  AS unsolved_incidents,
    ROUND(
        (COUNT(DISTINCT i.incident_id) - SUM(CASE WHEN i.situation LIKE '%Unknown%' THEN 1 ELSE 0 END)) 
        * 100.0 / NULLIF(COUNT(DISTINCT i.incident_id), 0), 2
    )                                                              AS clearance_rate_percent,
    COUNT(DISTINCT CASE 
        WHEN LOWER(w.description) LIKE '%gun%' 
          OR LOWER(w.description) LIKE '%firearm%' 
          OR LOWER(w.description) LIKE '%rifle%' 
          OR LOWER(w.description) LIKE '%shotgun%' 
        THEN i.incident_id 
    END)                                                           AS firearm_related_incidents,
    COUNT(DISTINCT CASE 
        WHEN LOWER(w.description) LIKE '%knife%' 
          OR LOWER(w.description) LIKE '%cutting%' 
        THEN i.incident_id 
    END)                                                           AS knife_related_incidents
FROM incident i
JOIN agency a 
    ON i.ori_code = a.ori_code
LEFT JOIN offender_involvement oi 
    ON i.incident_id = oi.incident_id
LEFT JOIN weapon w 
    ON oi.weapon_id = w.weapon_id
GROUP BY 
    a.state_name, 
    i.incident_year;
