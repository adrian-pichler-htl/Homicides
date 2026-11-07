-- ============================================================================
-- DBI Projekt "US Homicides (SHR)" - Teil 2 (SQL & Trigger)
-- Datei: run_all.sql
-- Beschreibung: Haupt-Ausführungsskript für Oracle SQL Developer / SQL*Plus.
--               Führt alle Teil-Skripte in der korrekten Reihenfolge aus.
-- ============================================================================

SET DEFINE OFF;
SET SQLBLANKLINES ON;
SET SERVEROUTPUT ON;
SET ECHO ON;
SET FEEDBACK ON;
SET LINESIZE 200;
SET PAGESIZE 100;

PROMPT ============================================================================
PROMPT SCHRITT 1: Erstellung des Schemas (DDL, Tabellen, Constraints)
PROMPT ============================================================================
@01_schema_ddl.sql

PROMPT ============================================================================
PROMPT SCHRITT 2: Erstellung der Views (Historical_Comparison_View)
PROMPT ============================================================================
@02_views.sql

PROMPT ============================================================================
PROMPT SCHRITT 3: Erstellung der PL/SQL Trigger (Before-Insert & After-Update)
PROMPT ============================================================================
@03_triggers.sql

PROMPT ============================================================================
PROMPT SCHRITT 4: Benutzerverwaltung & Berechtigungen (Rolle & 3 Benutzer)
PROMPT ============================================================================
@04_users_and_roles.sql

PROMPT ============================================================================
PROMPT SCHRITT 5: Laden des historischen Datensatzes 1985 (17.597 Vorfaelle)
PROMPT ============================================================================
@08_data_1985.sql

PROMPT ============================================================================
PROMPT SCHRITT 6: Laden des aktuellen Datensatzes 2025 (14.954 Vorfaelle)
PROMPT ============================================================================
@09_data_2025.sql

PROMPT ============================================================================
PROMPT SCHRITT 7: Ausführung der 3 komplexen SQL-Abfragen
PROMPT ============================================================================
@05_complex_queries.sql

PROMPT ============================================================================
PROMPT SCHRITT 8: Ausführung der 3 Data Dictionary Abfragen
PROMPT ============================================================================
@06_data_dictionary_queries.sql

PROMPT ============================================================================
PROMPT SCHRITT 9: Ausführung der Trigger-Funktionstests
PROMPT ============================================================================
@07_trigger_tests.sql

PROMPT ============================================================================
PROMPT Gesamtausführung erfolgreich abgeschlossen!
PROMPT ============================================================================

EXIT;
