-- ============================================================================
-- DBI Projekt "US Homicides (SHR)" - Teil 2 (SQL & Trigger)
-- Datei: 03_triggers.sql
-- Beschreibung: Definition der beiden geforderten Trigger gemäß Projektangabe 2.6
--               und Exposé (Before-Insert-Trigger und After-Update-Trigger).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Before-Insert-Trigger: trg_person_check_age
-- Tabelle: PERSON
-- Zweck: Validierung der Datenintegrität auf Anwendungslogikebene.
--        Stellt sicher, dass das Alter einer Person (Opfer oder Täter)
--        im plausiblen Wertebereich von 0 bis 120 Jahren liegt.
--        Bei unplausiblen Werten (z.B. -5 oder 250) wird die Transaktion
--        mittels RAISE_APPLICATION_ERROR (-20001) abgebrochen.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_person_check_age
BEFORE INSERT OR UPDATE OF age ON person
FOR EACH ROW
BEGIN
    IF :NEW.age IS NOT NULL THEN
        IF :NEW.age < 0 OR :NEW.age > 120 THEN
            RAISE_APPLICATION_ERROR(
                -20001, 
                'Fehler bei Personenanlage: Unplausibles Alter von ' || :NEW.age || 
                ' Jahren angegeben. Gültiger Bereich ist 0 bis 120 Jahre.'
            );
        END IF;
    END IF;
END;
/

-- ----------------------------------------------------------------------------
-- 2. After-Update-Trigger: trg_incident_audit_situation
-- Tabelle: INCIDENT
-- Zweck:
--        Wird ausgelöst, wenn sich die kriminalistische Aufklärungssituation 
--        (Spalte Situation) eines Vorfalls ändert (z.B. von 'Single Victim/Unknown Offender(s)'
--        zu 'Single Victim/Single Offender' nach Täteridentifikation).
--        Schreibt automatisch einen unveränderlichen Audit-Trail in AUDIT_LOG.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_incident_audit_situation
AFTER UPDATE OF situation ON incident
FOR EACH ROW
WHEN (OLD.situation IS NULL OR OLD.situation != NEW.situation)
BEGIN
    INSERT INTO audit_log (
        incident_id,
        old_situation,
        new_situation,
        changed_by,
        changed_at,
        action_type
    ) VALUES (
        :NEW.incident_id,
        :OLD.situation,
        :NEW.situation,
        USER,
        CURRENT_TIMESTAMP,
        'UPDATE'
    );
END;
/

