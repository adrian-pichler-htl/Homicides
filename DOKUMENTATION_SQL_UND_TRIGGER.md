# Meilenstein 4.2: SQL & Trigger – US Homicides (SHR)

## 1. Aktualisiertes ERD (Kapitel 2.3)

* **Feedback-Umsetzung:**
  * `victim_person_id` in `OFFENDER_INVOLVEMENT` ergänzt (Bezug zu konkretem Opfer).
  * Definition ungelöst: `situation LIKE '%Unknown Offender%'` bzw. `offender_count = 0`.
  * Eigene Tabelle `AUDIT_LOG` für den After-Update-Trigger ergänzt.

![Aktualisiertes ERD](erd/erd_updated.png)

---

## 2. SQL-Abfragen (Kapitel 2.5)

### 2.1 Abfrage 1: Vergleich Tötungsdelikte und Gesamtopferzahlen (1985 vs. 2025)
![Ergebnis Abfrage 1](screenshots/query1.png)

### 2.2 Abfrage 2: Top 5 Tatwaffen bei Beziehungstaten in Staaten mit hoher Fallzahl
![Ergebnis Abfrage 2](screenshots/query2.png)

### 2.3 Abfrage 3: Polizeibehörden mit überdurchschnittlich vielen ungelösten Fällen
![Ergebnis Abfrage 3](screenshots/query3.png)

---

## 3. Data Dictionary Abfragen (Kapitel 2.5)

### 3.1 Alle Tabellen und Spaltenanzahl
![Data Dictionary 1](screenshots/data1.png)

### 3.2 Spalten, Datentypen und Constraints für Tabelle INCIDENT

**Spalten und Datentypen:**  
![Data Dictionary 2 Spalten](screenshots/data2_1.png)

**Constraints:**  
![Data Dictionary 2 Constraints](screenshots/data2_2.png)

### 3.3 Berechtigungen von Rollen und Benutzern

**Berechtigungen der Rolle DataAnalyst:**  
![Data Dictionary 3 Rolle](screenshots/data3_1.png)

**Rechte von Benutzer PublicViewer:**  
![Data Dictionary 3 PublicViewer](screenshots/data3_2.png)

**Rollenzuweisung an Benutzer Investigator:**  
![Data Dictionary 3 Investigator](screenshots/data3_3.png)

---

## 4. Trigger (Kapitel 2.6)

### 4.1 Before-Insert-Trigger: Altersvalidierung (0–120 Jahre)
![Test Before-Insert](screenshots/trigger_result.png)

### 4.2 After-Update-Trigger: Audit-Log bei Statusänderung
![Test After-Update Audit Log](screenshots/trigger_result2.png)

---

## 5. View (Kapitel 2.7)

### Historical_Comparison_View
![Ergebnis View](screenshots/view.png)
