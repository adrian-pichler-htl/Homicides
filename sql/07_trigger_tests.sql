-- ============================================================================
-- DBI Projekt "US Homicides (SHR)" - Teil 2 (SQL & Trigger)
-- Datei: 07_trigger_tests.sql
-- Beschreibung: Minimaler Test beider Trigger (Erfolgs- und Fehlerfall)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Test Before-Insert-Trigger (trg_person_check_age auf PERSON)
-- ----------------------------------------------------------------------------

-- 1.1 Erfolgsfall (valides Alter: 25 Jahre)
INSERT INTO person (age, sex, race, ethnicity)
VALUES (25, 'M', 'White', 'Not of Hispanic Origin');

-- 1.2 Fehlerfall (ungueltiges Alter: 150 Jahre -> loest ORA-20001 aus)
INSERT INTO person (age, sex, race, ethnicity)
VALUES (150, 'M', 'Asian or Pacific Islander', 'Unknown');


-- ----------------------------------------------------------------------------
-- 2. Test After-Update-Trigger (trg_incident_audit_situation auf INCIDENT)
-- ----------------------------------------------------------------------------

-- 2.1 Test-Vorfall anlegen
INSERT INTO agency (ori_code, agency_name, state_name, population, county)
VALUES ('TEST001', 'Test Police Dept', 'Alaska', 50000, 'Test County');

INSERT INTO incident (ori_code, incident_year, incident_month, incident_number, situation, homicide_type, victim_count, offender_count, incident_date)
VALUES ('TEST001', 2025, 11, 'CASE-999', 'Single Victim/Unknown Offender(s)', 'Murder and Nonnegligent Manslaughter', 1, 0, DATE '2025-11-01');

-- 2.2 Situation aendern (loest After-Update-Trigger aus)
UPDATE incident 
SET situation = 'Single Victim/Single Offender',
    offender_count = 1
WHERE ori_code = 'TEST001' AND incident_number = 'CASE-999';

-- 2.3 Generierten Eintrag im Audit-Log anzeigen
SELECT * FROM audit_log;
