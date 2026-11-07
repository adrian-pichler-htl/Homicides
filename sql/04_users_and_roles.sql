-- ============================================================================
-- DBI Projekt "US Homicides (SHR)" - Teil 2 (SQL & Trigger)
-- Datei: 04_users_and_roles.sql
-- Beschreibung: Erstellung der Benutzer und Rollen mit abgestufter Rechtevergabe
--               gemäß Projektangabe 2.7 und Exposé:
--               - Rolle: DataAnalyst
--               - Benutzer: Investigator (zugewiesene Rolle DataAnalyst)
--               - Benutzer: AdminUser (Vollzugriff, DML & DDL)
--               - Benutzer: PublicViewer (nur Stammdaten & View)
-- ============================================================================

-- Erlaubt die Erstellung von Standardbenutzernamen auch in Pluggable Databases (PDBs)
-- ----------------------------------------------------------------------------
-- 0. Vorhandene Test-Benutzer und Rollen bereinigen (Idempotenz)
-- ----------------------------------------------------------------------------
BEGIN
    FOR u IN (SELECT username FROM all_users WHERE username IN ('INVESTIGATOR', 'ADMINUSER', 'PUBLICVIEWER')) LOOP
        EXECUTE IMMEDIATE 'DROP USER ' || u.username || ' CASCADE';
    END LOOP;
    FOR r IN (SELECT role FROM dba_roles WHERE role = 'DATAANALYST') LOOP
        EXECUTE IMMEDIATE 'DROP ROLE ' || r.role;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- ----------------------------------------------------------------------------
-- 1. Rolle: DATAANALYST
-- Zweck: Leserechte (SELECT) auf alle operativen Tabellen und Views
--        zur Durchführung statistischer Auswertungen.
-- ----------------------------------------------------------------------------
CREATE ROLE DataAnalyst;

GRANT CREATE SESSION TO DataAnalyst;
GRANT SELECT ON agency TO DataAnalyst;
GRANT SELECT ON incident TO DataAnalyst;
GRANT SELECT ON person TO DataAnalyst;
GRANT SELECT ON weapon TO DataAnalyst;
GRANT SELECT ON circumstance TO DataAnalyst;
GRANT SELECT ON victim_involvement TO DataAnalyst;
GRANT SELECT ON offender_involvement TO DataAnalyst;
GRANT SELECT ON audit_log TO DataAnalyst;
GRANT SELECT ON historical_comparison_view TO DataAnalyst;

-- ----------------------------------------------------------------------------
-- 2. Benutzer: INVESTIGATOR
-- Zweck: Kriminalbeamter / Ermittler, der Daten analysiert.
--        Erhält die Rolle DataAnalyst zugewiesen.
-- ----------------------------------------------------------------------------
CREATE USER Investigator IDENTIFIED BY "Investigator_2026!"
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON users
    ACCOUNT UNLOCK;

GRANT DataAnalyst TO Investigator;
ALTER USER Investigator DEFAULT ROLE DataAnalyst;

-- ----------------------------------------------------------------------------
-- 3. Benutzer: ADMINUSER
-- Zweck: Systemadministrator mit Vollzugriff (Lesen, Schreiben, DML, DDL)
--        auf alle Tabellen und Views des Datenbankschemas.
-- ----------------------------------------------------------------------------
CREATE USER AdminUser IDENTIFIED BY "AdminUser_2026!"
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON users
    ACCOUNT UNLOCK;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE TRIGGER, 
      CREATE PROCEDURE, CREATE SEQUENCE TO AdminUser;

GRANT SELECT, INSERT, UPDATE, DELETE ON agency TO AdminUser;
GRANT SELECT, INSERT, UPDATE, DELETE ON incident TO AdminUser;
GRANT SELECT, INSERT, UPDATE, DELETE ON person TO AdminUser;
GRANT SELECT, INSERT, UPDATE, DELETE ON weapon TO AdminUser;
GRANT SELECT, INSERT, UPDATE, DELETE ON circumstance TO AdminUser;
GRANT SELECT, INSERT, UPDATE, DELETE ON victim_involvement TO AdminUser;
GRANT SELECT, INSERT, UPDATE, DELETE ON offender_involvement TO AdminUser;
GRANT SELECT, INSERT, UPDATE, DELETE ON audit_log TO AdminUser;
GRANT SELECT ON historical_comparison_view TO AdminUser;

-- ----------------------------------------------------------------------------
-- 4. Benutzer: PUBLICVIEWER
-- Zweck: Externer Bürger oder Journalist.
--        Erhält strikt begrenzte Leserechte:
--        - Nur Stammdaten (AGENCY, WEAPON)
--        - Nur die aggregierte View HISTORICAL_COMPARISON_VIEW
--        - KEIN Zugriff auf INCIDENT, PERSON, OPFER/TÄTER oder AUDIT_LOG
-- ----------------------------------------------------------------------------
CREATE USER PublicViewer IDENTIFIED BY "PublicViewer_2026!"
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    ACCOUNT UNLOCK;

GRANT CREATE SESSION TO PublicViewer;
GRANT SELECT ON agency TO PublicViewer;
GRANT SELECT ON weapon TO PublicViewer;
GRANT SELECT ON historical_comparison_view TO PublicViewer;

