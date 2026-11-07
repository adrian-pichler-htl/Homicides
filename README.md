# US Homicides (SHR) - Datenbankprojekt Teil 2 (SQL & Trigger)

**Projekt:** US Homicides (SHR) FBI Kriminalitätsstatistik (1985 & 2025)  
**Klasse:** 5BHIF, HTL Leonding  
**Lehrkraft:** S. Ivčević  
**Abgabe:** Meilenstein 4.2 (SQL & Trigger)

---

## Kurzübersicht der Abgabe-Inhalte

Gemäß den Anforderungen aus `Projektangabe_5DBI.pdf` (Abschnitt 4.2) und dem Lehrerfeedback aus Teil 1:

1. **DDL-Skripte (2.4 Relationale Datenbank):**
   - 8 Tabellen inklusive Primärschlüssel, Fremdschlüssel, Unique-Constraints, NOT NULL, Check-Constraints und Default-Werte.
   - Haupttabelle `INCIDENT` mit über 27.000 Datensätzen (Anforderung: $\ge 20.000$ Zeilen) mit Zeit- und numerischen Attributen.
   - 2 m:n-Beziehungen (`VICTIM_INVOLVEMENT` und `OFFENDER_INVOLVEMENT`).
   - Revisionssichere Tabelle `AUDIT_LOG` für den After-Update-Trigger (Feedback-Umsetzung).
   - `Victim_Person_ID` in `OFFENDER_INVOLVEMENT` zur eindeutigen Klärung von *"Relationship zu wem?"* (Feedback-Umsetzung).

2. **SQL-Abfragen (2.5):**
   - 3 komplexe SQL-Abfragen mit vollständiger Abdeckung von: `JOIN`, `GROUP BY`, `AVG`, `SUM`, `COUNT`, `ORDER BY`, `Subquery mit IN/ALL/ANY/EXISTS`.
   - Klärung des Feedbacks *"Was ist ungelöst?"*: Kriminologische Definition über `situation LIKE '%Unknown Offender%'`.
   - 3 Data Dictionary Abfragen zu Tabellen & Spaltenanzahl, `INCIDENT`-Constraints und Berechtigungen.

3. **PL/SQL-Trigger (2.6):**
   - **Before-Insert-Trigger (`trg_person_check_age`):** Validiert Alter (0–120 Jahre) auf `PERSON`, wirft Exception `ORA-20001` bei unplausiblen Werten.
   - **After-Update-Trigger (`trg_incident_audit_situation`):** Schreibt bei Statusänderungen automatisch einen Audit-Eintrag in `AUDIT_LOG`.

4. **Benutzerrechte & Views (2.7):**
   - View `Historical_Comparison_View` (multi-table JOIN, Kennzahlen 1985 vs. 2025).
   - 1 Rolle (`DataAnalyst`) und 3 Benutzer (`Investigator`, `AdminUser`, `PublicViewer`).

5. **Aktualisiertes ERD:**
   - Als Grafik (`erd/erd_updated.png`), Vektordatei (`erd/erd_updated.svg`) und PlantUML (`erd/erd_updated.puml`).

6. **Screenshots:**
   - Alle Abfragen, Data Dictionary Ausgaben und Trigger-Funktionstests mit formatierter Ergebnisausgabe in `screenshots/`.

---

## Schnellanleitung zur Ausführung

In **Oracle SQL Developer** oder **SQL*Plus**:
```sql
@sql/run_all.sql
```
Dieses Skript führt alle Teilschritte (DDL, Views, Trigger, Benutzerrechte, Testdaten, Abfragen, Trigger-Tests) in der richtigen Reihenfolge aus.

