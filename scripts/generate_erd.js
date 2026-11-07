const fs = require('fs');
const path = require('path');

function generateERDSVG() {
    const width = 1600;
    const height = 1100;

    const tables = [
        {
            name: "AGENCY",
            x: 50,
            y: 50,
            width: 280,
            rows: [
                ["string", "ORI_Code", "PK"],
                ["string", "Agency_Name", ""],
                ["string", "State_Name", ""],
                ["int", "Population", ""],
                ["string", "County", ""]
            ]
        },
        {
            name: "INCIDENT",
            x: 50,
            y: 280,
            width: 290,
            rows: [
                ["int", "Incident_ID", "PK"],
                ["string", "ORI_Code", "FK"],
                ["int", "Year", ""],
                ["int", "Month", ""],
                ["string", "Incident_Number", ""],
                ["string", "Situation", ""],
                ["string", "Homicide_Type", ""],
                ["int", "Victim_Count", ""],
                ["int", "Offender_Count", ""],
                ["date", "Incident_Date", ""]
            ]
        },
        {
            name: "AUDIT_LOG",
            x: 50,
            y: 670,
            width: 290,
            highlight: true,
            note: "Neu (Feedback 3): Eigene Tabelle",
            rows: [
                ["int", "Log_ID", "PK"],
                ["int", "Incident_ID", "FK"],
                ["string", "Old_Situation", ""],
                ["string", "New_Situation", ""],
                ["string", "Changed_By", ""],
                ["timestamp", "Changed_At", ""],
                ["string", "Action_Type", ""]
            ]
        },
        {
            name: "PERSON",
            x: 480,
            y: 280,
            width: 270,
            rows: [
                ["int", "Person_ID", "PK"],
                ["int", "Age", ""],
                ["char", "Sex", ""],
                ["string", "Race", ""],
                ["string", "Ethnicity", ""]
            ]
        },
        {
            name: "VICTIM_INVOLVEMENT",
            x: 480,
            y: 520,
            width: 270,
            rows: [
                ["int", "Incident_ID", "PK,FK"],
                ["int", "Person_ID", "PK,FK"],
                ["int", "Victim_Sequence", ""]
            ]
        },
        {
            name: "OFFENDER_INVOLVEMENT",
            x: 850,
            y: 520,
            width: 330,
            highlight: true,
            note: "Aktualisiert (Feedback 1)",
            rows: [
                ["int", "Incident_ID", "PK,FK"],
                ["int", "Person_ID", "PK,FK (Täter)"],
                ["int", "Victim_Person_ID", "FK (Opfer) *"],
                ["int", "Weapon_ID", "FK"],
                ["int", "Circumstance_ID", "FK"],
                ["string", "Relationship", ""],
                ["int", "Offender_Sequence", ""]
            ]
        },
        {
            name: "WEAPON",
            x: 850,
            y: 280,
            width: 270,
            rows: [
                ["int", "Weapon_ID", "PK"],
                ["string", "Weapon_Code", ""],
                ["string", "Description", "UQ"]
            ]
        },
        {
            name: "CIRCUMSTANCE",
            x: 1220,
            y: 280,
            width: 290,
            rows: [
                ["int", "Circumstance_ID", "PK"],
                ["string", "Circumstance_Code", ""],
                ["string", "Description", "UQ"]
            ]
        }
    ];

    let svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}" style="background-color: #F8F9FA; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">\n`;

    // Gradients and Filters
    svg += `
    <defs>
        <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
            <feDropShadow dx="2" dy="3" stdDeviation="3" flood-opacity="0.12"/>
        </filter>
        <marker id="crowfoot" viewBox="0 0 20 20" refX="18" refY="10" markerWidth="12" markerHeight="12" orient="auto">
            <path d="M 0 0 L 18 10 L 0 20 M 18 0 L 18 20" fill="none" stroke="#6C5CE7" stroke-width="2"/>
        </marker>
        <marker id="circle-crowfoot" viewBox="0 0 24 20" refX="22" refY="10" markerWidth="14" markerHeight="12" orient="auto">
            <circle cx="6" cy="10" r="4" fill="#F8F9FA" stroke="#6C5CE7" stroke-width="2"/>
            <path d="M 10 2 L 22 10 L 10 18 M 22 2 L 22 18" fill="none" stroke="#6C5CE7" stroke-width="2"/>
        </marker>
        <marker id="one-and-only-one" viewBox="0 0 20 20" refX="10" refY="10" markerWidth="10" markerHeight="10" orient="auto">
            <line x1="6" y1="2" x2="6" y2="18" stroke="#6C5CE7" stroke-width="2"/>
            <line x1="12" y1="2" x2="12" y2="18" stroke="#6C5CE7" stroke-width="2"/>
        </marker>
    </defs>
    `;

    // Title & Legend
    svg += `
    <!-- Header Title -->
    <text x="50" y="38" font-size="22" font-weight="bold" fill="#2D3436">US Homicides (SHR) - Aktualisiertes Entity-Relationship-Diagramm (ERD)</text>
    
    <!-- Legend / Feedback Box -->
    <g transform="translate(850, 40)" filter="url(#shadow)">
        <rect width="660" height="190" rx="8" fill="#FFFFFF" stroke="#00B894" stroke-width="2"/>
        <rect width="660" height="32" rx="8" fill="#00B894"/>
        <text x="15" y="22" font-size="14" font-weight="bold" fill="#FFFFFF">Feedback-Umsetzung &amp; Kriminologische Begriffsklärungen</text>
        
        <text x="15" y="55" font-size="12" font-weight="bold" fill="#2D3436">1. Eigene Tabelle für After-Update-Trigger (Feedback 3):</text>
        <text x="30" y="73" font-size="11" fill="#636E72">• Tabelle AUDIT_LOG als eigenständige Entität hinzugefügt (protokolliert Änderungen an Situation).</text>
        
        <text x="15" y="95" font-size="12" font-weight="bold" fill="#2D3436">2. Relationship zu wem? (Feedback 1):</text>
        <text x="30" y="113" font-size="11" fill="#636E72">• In OFFENDER_INVOLVEMENT referenziert Victim_Person_ID explizit das spezifische Opfer (PERSON).</text>
        <text x="30" y="128" font-size="11" fill="#636E72">• Relationship definiert die konkrete Beziehung des Täters zu DIESEM Opfer (z.B. Wife, Friend, Stranger).</text>
        
        <text x="15" y="150" font-size="12" font-weight="bold" fill="#2D3436">3. Was ist ungelöst? (Feedback 2):</text>
        <text x="30" y="168" font-size="11" fill="#636E72">• Unsolved / Cold Case: Situation IN ('Single/Multiple Victims/Unknown Offender(s)') bzw. Offender_Count = 0.</text>
    </g>
    `;

    // Relationship lines
    const lines = [
        // AGENCY -> INCIDENT (1:n)
        { x1: 195, y1: 190, x2: 195, y2: 280, label: "meldet" },
        // INCIDENT -> AUDIT_LOG (1:n)
        { x1: 195, y1: 570, x2: 195, y2: 670, label: "protokolliert" },
        // INCIDENT -> VICTIM_INVOLVEMENT (1:n)
        { x1: 340, y1: 420, x2: 480, y2: 560, label: "hat Opfer" },
        // PERSON -> VICTIM_INVOLVEMENT (1:n)
        { x1: 615, y1: 420, x2: 615, y2: 520, label: "involviert als Opfer" },
        // INCIDENT -> OFFENDER_INVOLVEMENT (1:n)
        { x1: 340, y1: 450, x2: 850, y2: 590, label: "hat Täter" },
        // PERSON -> OFFENDER_INVOLVEMENT (1:n) [Täter]
        { x1: 750, y1: 350, x2: 850, y2: 540, label: "involviert als Täter" },
        // PERSON -> OFFENDER_INVOLVEMENT (1:n) [Opfer-Referenz]
        { x1: 750, y1: 380, x2: 850, y2: 565, label: "Bezugsopfer (*)" },
        // WEAPON -> OFFENDER_INVOLVEMENT (1:n)
        { x1: 985, y1: 390, x2: 985, y2: 520, label: "verwendet bei" },
        // CIRCUMSTANCE -> OFFENDER_INVOLVEMENT (1:n)
        { x1: 1365, y1: 390, x2: 1100, y2: 520, label: "passierte unter" }
    ];

    lines.forEach(l => {
        svg += `
        <line x1="${l.x1}" y1="${l.y1}" x2="${l.x2}" y2="${l.y2}" stroke="#6C5CE7" stroke-width="2" marker-start="url(#one-and-only-one)" marker-end="url(#circle-crowfoot)"/>
        <rect x="${(l.x1 + l.x2) / 2 - 40}" y="${(l.y1 + l.y2) / 2 - 10}" width="80" height="18" rx="4" fill="#FFFFFF" fill-opacity="0.85"/>
        <text x="${(l.x1 + l.x2) / 2}" y="${(l.y1 + l.y2) / 2 + 3}" font-size="10" font-weight="bold" fill="#6C5CE7" text-anchor="middle">${l.label}</text>
        `;
    });

    // Render Tables
    tables.forEach(t => {
        const headerHeight = 32;
        const rowHeight = 24;
        const totalHeight = headerHeight + t.rows.length * rowHeight;
        const headerBg = t.highlight ? "#6C5CE7" : "#EBE8F9";
        const headerTextColor = t.highlight ? "#FFFFFF" : "#4834D4";
        const borderColor = t.highlight ? "#6C5CE7" : "#B2BEC3";

        svg += `
        <!-- Table: ${t.name} -->
        <g transform="translate(${t.x}, ${t.y})" filter="url(#shadow)">
            <rect width="${t.width}" height="${totalHeight}" rx="6" fill="#FFFFFF" stroke="${borderColor}" stroke-width="${t.highlight ? 2 : 1.5}"/>
            <path d="M 0 6 Q 0 0 6 0 L ${t.width - 6} 0 Q ${t.width} 0 ${t.width} 6 L ${t.width} ${headerHeight} L 0 ${headerHeight} Z" fill="${headerBg}"/>
            <text x="${t.width / 2}" y="21" font-size="13" font-weight="bold" fill="${headerTextColor}" text-anchor="middle">${t.name}</text>
        `;

        if (t.note) {
            svg += `<text x="${t.width - 8}" y="12" font-size="8" font-weight="bold" fill="${t.highlight ? '#FFEAA7' : '#00B894'}" text-anchor="end">${t.note}</text>`;
        }

        t.rows.forEach((r, idx) => {
            const rowY = headerHeight + idx * rowHeight;
            const bg = (idx % 2 === 0) ? "#FFFFFF" : "#F8F9FA";
            const isPK = r[2].includes("PK");
            const isFK = r[2].includes("FK");
            const keyColor = isPK ? "#E17055" : (isFK ? "#0984E3" : "#B2BEC3");
            const textColor = (isPK || isFK) ? "#2D3436" : "#636E72";
            const fontWt = (isPK || isFK) ? "bold" : "normal";

            svg += `
            <rect x="0" y="${rowY}" width="${t.width}" height="${rowHeight}" fill="${bg}" stroke="#DFE6E9" stroke-width="0.5"/>
            <text x="10" y="${rowY + 16}" font-size="11" fill="#A4B0BE" font-family="monospace">${r[0]}</text>
            <text x="75" y="${rowY + 16}" font-size="11" font-weight="${fontWt}" fill="${textColor}">${r[1]}</text>
            <text x="${t.width - 10}" y="${rowY + 16}" font-size="10" font-weight="bold" fill="${keyColor}" text-anchor="end">${r[2]}</text>
            `;
        });

        svg += `</g>\n`;
    });

    svg += `</svg>`;
    return svg;
}

const outDir = path.join(__dirname, '..', 'erd');
if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
}

const svgContent = generateERDSVG();
const svgPath = path.join(outDir, 'erd_updated.svg');
fs.writeFileSync(svgPath, svgContent, 'utf8');
console.log(`Updated ERD SVG saved to: ${svgPath}`);

// Also generate PlantUML source for versatility
const pumlContent = `@startuml US_Homicides_Updated_ERD
!theme plain
skinparam linetype ortho
skinparam roundcorner 5

entity "AGENCY" as agency {
    * ORI_Code : VARCHAR2(7) <<PK>>
    --
    * Agency_Name : VARCHAR2(100)
    * State_Name : VARCHAR2(50)
    * Population : NUMBER(10)
    County : VARCHAR2(50)
}

entity "INCIDENT" as incident {
    * Incident_ID : NUMBER <<PK>>
    --
    * ORI_Code : VARCHAR2(7) <<FK>>
    * Year : NUMBER(4)
    * Month : NUMBER(2)
    * Incident_Number : VARCHAR2(20)
    * Situation : VARCHAR2(60)
    * Homicide_Type : VARCHAR2(60)
    * Victim_Count : NUMBER(3)
    * Offender_Count : NUMBER(3)
    * Incident_Date : DATE
}

entity "AUDIT_LOG" as audit_log {
    * Log_ID : NUMBER <<PK>>
    --
    * Incident_ID : NUMBER <<FK>>
    Old_Situation : VARCHAR2(60)
    * New_Situation : VARCHAR2(60)
    * Changed_By : VARCHAR2(100)
    * Changed_At : TIMESTAMP
    * Action_Type : VARCHAR2(20)
}

entity "PERSON" as person {
    * Person_ID : NUMBER <<PK>>
    --
    Age : NUMBER(3)
    * Sex : CHAR(1)
    * Race : VARCHAR2(50)
    * Ethnicity : VARCHAR2(50)
}

entity "WEAPON" as weapon {
    * Weapon_ID : NUMBER <<PK>>
    --
    Weapon_Code : VARCHAR2(10)
    * Description : VARCHAR2(100) <<UQ>>
}

entity "CIRCUMSTANCE" as circumstance {
    * Circumstance_ID : NUMBER <<PK>>
    --
    Circumstance_Code : VARCHAR2(10)
    * Description : VARCHAR2(150) <<UQ>>
}

entity "VICTIM_INVOLVEMENT" as victim_inv {
    * Incident_ID : NUMBER <<PK,FK>>
    * Person_ID : NUMBER <<PK,FK>>
    --
    * Victim_Sequence : NUMBER(2)
}

entity "OFFENDER_INVOLVEMENT" as offender_inv {
    * Incident_ID : NUMBER <<PK,FK>>
    * Person_ID : NUMBER <<PK,FK>> (Täter)
    --
    Victim_Person_ID : NUMBER <<FK>> (Opfer)
    * Weapon_ID : NUMBER <<FK>>
    * Circumstance_ID : NUMBER <<FK>>
    * Relationship : VARCHAR2(60)
    * Offender_Sequence : NUMBER(2)
}

agency ||--o{ incident : "meldet"
incident ||--o{ audit_log : "protokolliert"
incident ||--o{ victim_inv : "hat Opfer"
person ||--o{ victim_inv : "involviert als"
incident ||--o{ offender_inv : "hat Täter"
person ||--o{ offender_inv : "involviert als Täter"
person ||--o{ offender_inv : "referenziert als Opfer"
weapon ||--o{ offender_inv : "verwendet bei"
circumstance ||--o{ offender_inv : "passierte unter"

note right of offender_inv
  **Klarstellung (Feedback 1):**
  Victim_Person_ID klärt "Relationship zu wem?".
  Relationship definiert die Beziehung des Täters
  zum jeweiligen Opfer.
end note

note right of audit_log
  **Klarstellung (Feedback 3):**
  AUDIT_LOG als eigenständige Tabelle
  für den After-Update-Trigger.
end note

@enduml
`;

const pumlPath = path.join(outDir, 'erd_updated.puml');
fs.writeFileSync(pumlPath, pumlContent, 'utf8');
console.log(`Updated ERD PlantUML saved to: ${pumlPath}`);

