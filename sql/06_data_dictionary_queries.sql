-- ============================================================================
-- DBI Projekt "US Homicides (SHR)" - Teil 2 (SQL & Trigger)
-- Datei: 06_data_dictionary_queries.sql
-- Beschreibung: 3 Abfragen an das Oracle Data Dictionary gemäß Projektangabe 2.5
--               und Exposé zur Inspektion von Metadaten, Schema-Definitionen
--               und Benutzerrechten.
-- ============================================================================

-- ============================================================================
-- DATA DICTIONARY ABFRAGE 1: Ausgabe aller Tabellen und deren Spaltenanzahl
-- ============================================================================
-- Beschreibung:
-- Greift auf USER_TABLES und USER_TAB_COLUMNS zu. Zeigt alle im aktuellen
-- Schema erstellten Tabellen, die Anzahl der jeweils definierten Spalten,
-- den zugewiesenen Tablespace sowie die erfassten Zeilenzahlen (sofern Statistiken
-- berechnet wurden).
-- ============================================================================

SELECT 
    t.table_name,
    COUNT(c.column_name) AS column_count,
    t.tablespace_name,
    t.status
FROM user_tables t
JOIN user_tab_columns c 
    ON t.table_name = c.table_name
GROUP BY 
    t.table_name, 
    t.tablespace_name, 
    t.status
ORDER BY 
    t.table_name;


-- ============================================================================
-- DATA DICTIONARY ABFRAGE 2: Constraints, Datentypen und Längen für Tabelle INCIDENT
-- ============================================================================
-- Beschreibung:
-- Inspiziert die Haupttabelle INCIDENT im Detail.
-- Teil A: Spaltendefinitionen, Datentypen, Längen, Nullable-Eigenschaften und Defaults.
-- Teil B: Alle Constraints (PK, FK, Unique, Check) inklusive betroffener Spalten
--         und referenzierter Fremdschlüsseltabellen.
-- ============================================================================

-- Teil A: Spalten- und Datentyp-Metadaten
SELECT 
    column_id,
    column_name,
    data_type || 
    CASE 
        WHEN data_type IN ('VARCHAR2', 'CHAR') THEN '(' || data_length || ')'
        WHEN data_type = 'NUMBER' AND data_precision IS NOT NULL AND data_scale IS NOT NULL 
             THEN '(' || data_precision || ',' || data_scale || ')'
        WHEN data_type = 'NUMBER' AND data_precision IS NOT NULL 
             THEN '(' || data_precision || ')'
        ELSE ''
    END AS formatted_datatype,
    nullable,
    data_default
FROM user_tab_columns
WHERE table_name = 'INCIDENT'
ORDER BY column_id;

-- Teil B: Constraints und Beziehungen
SELECT 
    uc.constraint_name,
    CASE uc.constraint_type
        WHEN 'P' THEN 'PRIMARY KEY'
        WHEN 'R' THEN 'FOREIGN KEY'
        WHEN 'U' THEN 'UNIQUE'
        WHEN 'C' THEN 'CHECK'
        ELSE uc.constraint_type
    END AS constraint_type,
    ucc.column_name,
    uc.search_condition,
    r_uc.table_name AS referenced_table
FROM user_constraints uc
LEFT JOIN user_cons_columns ucc 
    ON uc.constraint_name = ucc.constraint_name
LEFT JOIN user_constraints r_uc 
    ON uc.r_constraint_name = r_uc.constraint_name
WHERE uc.table_name = 'INCIDENT'
ORDER BY 
    uc.constraint_type, 
    uc.constraint_name, 
    ucc.position;


-- ============================================================================
-- DATA DICTIONARY ABFRAGE 3: Berechtigungen der Rolle DataAnalyst und des
--                            Benutzers PublicViewer
-- ============================================================================
-- Beschreibung:
-- Verifiziert das implementierte Berechtigungskonzept aus 2.7.
-- Teil A: Berechtigungen der Rolle DataAnalyst auf Schema-Objekte (ROLE_TAB_PRIVS).
-- Teil B: Dem Benutzer PublicViewer direkt zugewiesene Objektberechtigungen (ALL_TAB_PRIVS).
-- Teil C: Rollenzuweisung an den Benutzer Investigator (DBA_ROLE_PRIVS bzw. USER_ROLE_PRIVS).
-- ============================================================================

-- Teil A: Objekt-Rechte der Rolle DataAnalyst
SELECT 
    role,
    table_name,
    privilege
FROM role_tab_privs
WHERE role = 'DATAANALYST'
ORDER BY table_name, privilege;

-- Teil B: Objekt-Rechte des Benutzers PublicViewer
SELECT 
    grantee,
    table_name,
    privilege,
    grantor
FROM all_tab_privs
WHERE grantee = 'PUBLICVIEWER'
ORDER BY table_name, privilege;

-- Teil C: Rollenzuweisung an Benutzer Investigator
SELECT 
    grantee,
    granted_role,
    admin_option,
    default_role
FROM dba_role_privs
WHERE grantee IN ('INVESTIGATOR', 'PUBLICVIEWER', 'ADMINUSER')
ORDER BY grantee, granted_role;

