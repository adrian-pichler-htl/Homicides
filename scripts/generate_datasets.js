const fs = require('fs');
const readline = require('readline');
const path = require('path');

function parseLine(text) {
    const p = [];
    let cur = '';
    let inQuotes = false;
    for (let i = 0; i < text.length; i++) {
        const c = text[i];
        if (c === '"') inQuotes = !inQuotes;
        else if (c === ',' && !inQuotes) {
            p.push(cur.trim());
            cur = '';
        } else cur += c;
    }
    p.push(cur.trim());
    return p;
}

function escapeSQL(str) {
    if (str === null || str === undefined) return "NULL";
    return "'" + String(str).replace(/'/g, "''") + "'";
}

const weaponList = [
    'Firearm, type not stated', 'Handgun', 'Rifle', 'Shotgun', 'Other Gun',
    'Knife/Cutting Instrument', 'Blunt Object', 'Personal Weapons', 'Poison',
    'Pushed or thrown out window', 'Explosives', 'Fire', 'Narcotics/Drugs',
    'Drowning', 'Strangulation - hanging', 'Asphyxiation', 'Other'
];

const circList = [
    'Rape', 'Robbery', 'Burglary', 'Larceny', 'Motor Vehicle Theft', 'Arson',
    'Prostitution and Commercialized Vice', 'Narcotic Drug Laws', 'Other - not specified',
    "Lover's Triangle", 'Brawl Due to Influence of Alcohol', 'Brawl Due to Influence of Narcotics',
    'Argument Over Money or Property', 'Other Arguments', 'Gangland Killings',
    'Juvenile Gang Killings', 'Felon Killed by Private Citizen', 'Felon Killed by Police',
    'Unable to Determine', 'Other', 'Other Sex Offenses', 'Institutional Killings',
    'Children Playing With Gun', 'Child Killed by Babysitter', 'Victim Shot in Hunting Accident',
    'Gun-Cleaning Death', 'Gambling', 'All Suspected Felony Type',
    'All Other Manslaughter by Negligence', 'Other Negligent Handling of Gun',
    'Sniper Attack', 'Abortion'
];

const weaponMap = new Map();
weaponList.forEach((w, i) => weaponMap.set(w.toLowerCase(), i + 1));

const circMap = new Map();
circList.forEach((c, i) => circMap.set(c.toLowerCase(), i + 1));

function getWeaponId(name) {
    if (!name) return weaponMap.get('other');
    const lower = name.toLowerCase().trim();
    return weaponMap.get(lower) || weaponMap.get('other');
}

function getCircId(name) {
    if (!name) return circMap.get('unable to determine');
    const lower = name.toLowerCase().trim();
    return circMap.get(lower) || circMap.get('unable to determine');
}

function parseSex(str) {
    if (str === 'Male' || str === 'M') return 'M';
    if (str === 'Female' || str === 'F') return 'F';
    return 'U';
}

function parseAge(str) {
    let num = parseInt(str, 10);
    if (isNaN(num) || num < 0 || num > 120 || num === 99 || num === 999) return 'NULL';
    return num;
}

function parseRace(str) {
    const valid = ['White', 'Black', 'American Indian or Alaskan Native', 'Asian or Pacific Islander', 'Unknown'];
    if (valid.includes(str)) return str;
    return 'Unknown';
}

function parseEth(str) {
    if (str === 'Hispanic Origin') return 'Hispanic Origin';
    if (str === 'Not of Hispanic Origin') return 'Not of Hispanic Origin';
    return 'Unknown';
}

async function convertFile(csvPath, outSqlPath, defaultYear) {
    console.log(`Processing ${csvPath} -> ${outSqlPath} (Year: ${defaultYear})...`);
    const rl = readline.createInterface({ input: fs.createReadStream(csvPath), crlfDelay: Infinity });
    const out = fs.createWriteStream(outSqlPath, { encoding: 'utf8' });

    out.write('-- ============================================================================\n');
    out.write(`-- FBI Supplementary Homicide Reports (SHR) - Datensatz ${defaultYear}\n`);
    out.write(`-- Automatisch generiert aus ${path.basename(csvPath)}\n`);
    out.write('-- ============================================================================\n\n');
    out.write('SET DEFINE OFF;\n');
    out.write('SET SQLBLANKLINES ON;\n');
    out.write('SET FEEDBACK OFF;\n\n');

    // 1. Catalogs
    out.write('-- ----------------------------------------------------------------------------\n');
    out.write('-- Stammdaten: Waffen & Tatumstaende\n');
    out.write('-- ----------------------------------------------------------------------------\n');
    out.write('BEGIN\n');
    weaponList.forEach((w, i) => {
        out.write(`  MERGE INTO weapon d USING (SELECT ${i + 1} AS id, ${escapeSQL(w)} AS dsc FROM dual) s ` +
                  `ON (d.weapon_id = s.id) WHEN NOT MATCHED THEN INSERT (weapon_id, weapon_code, description) VALUES (s.id, 'W${i + 1}', s.dsc);\n`);
    });
    circList.forEach((c, i) => {
        out.write(`  MERGE INTO circumstance d USING (SELECT ${i + 1} AS id, ${escapeSQL(c)} AS dsc FROM dual) s ` +
                  `ON (d.circumstance_id = s.id) WHEN NOT MATCHED THEN INSERT (circumstance_id, circumstance_code, description) VALUES (s.id, 'C${i + 1}', s.dsc);\n`);
    });
    out.write('  COMMIT;\nEND;\n/\n\n');

    const agencies = new Map();
    const seenIncKeys = new Set();
    const incidents = [];
    let rowIdx = 0;

    for await (const line of rl) {
        rowIdx++;
        if (rowIdx === 1) continue; // Skip header
        const row = parseLine(line);
        if (row.length < 25) continue;

        const ori = (row[2] || '').padEnd(7, '0').substring(0, 7);
        if (ori.length !== 7) continue;

        let state = 'Unknown';
        if (row[1] && row[1].includes('-')) {
            state = row[1].split('-')[1].trim();
        } else if (row[11]) {
            state = row[11].trim();
        }

        const agencyName = (row[10] || 'POLICE DEPT').substring(0, 100);
        let pop = parseInt(row[6], 10);
        if (isNaN(pop) || pop < 0) pop = 0;
        const county = (row[7] || '').substring(0, 50);

        if (!agencies.has(ori)) {
            agencies.set(ori, { ori, agencyName, state, pop, county });
        }

        const month = Math.max(1, Math.min(12, parseInt(row[12], 10) || 1));
        let incNum = (row[16] || `INC-${rowIdx}`).substring(0, 20);
        const incKey = `${ori}_${month}_${incNum}`;
        if (seenIncKeys.has(incKey)) {
            incNum = (incNum + `-${rowIdx}`).substring(0, 20);
        }
        seenIncKeys.add(`${ori}_${month}_${incNum}`);

        let situation = row[17] || 'Single Victim/Single Offender';
        let homType = row[15] || 'Murder and Nonnegligent Manslaughter';
        let vicCount = Math.max(1, parseInt(row[30], 10) || 1);
        let offCount = parseInt(row[31], 10);
        if (isNaN(offCount) || offCount < 0) {
            offCount = situation.includes('Unknown') ? 0 : 1;
        }

        // Vic 1
        const vicAge = parseAge(row[18]);
        const vicSex = parseSex(row[19]);
        const vicRace = parseRace(row[20]);
        const vicEth = parseEth(row[21]);

        // Off 1
        const isUnknownOff = situation.includes('Unknown') || offCount === 0;
        const offAge = isUnknownOff ? 'NULL' : parseAge(row[22]);
        const offSex = isUnknownOff ? 'U' : parseSex(row[23]);
        const offRace = isUnknownOff ? 'Unknown' : parseRace(row[24]);
        const offEth = isUnknownOff ? 'Unknown' : parseEth(row[25]);
        const weaponId = getWeaponId(row[26]);
        const circId = getCircId(row[28]);
        const rel = isUnknownOff ? 'Unknown Relationship' : (row[27] || 'Unknown Relationship').substring(0, 60);

        incidents.push({
            ori,
            year: defaultYear,
            month,
            incNum,
            situation,
            homType,
            vicCount,
            offCount,
            vicAge, vicSex, vicRace, vicEth,
            isUnknownOff,
            offAge, offSex, offRace, offEth,
            weaponId, circId, rel
        });
    }

    console.log(`Parsed ${incidents.length} incidents, ${agencies.size} agencies.`);

    // 2. Agencies
    out.write('-- ----------------------------------------------------------------------------\n');
    out.write(`-- Meldebehoerden (${agencies.size} Agencies)\n`);
    out.write('-- ----------------------------------------------------------------------------\n');
    const agencyBatch = 500;
    const agList = Array.from(agencies.values());
    for (let i = 0; i < agList.length; i += agencyBatch) {
        out.write('BEGIN\n');
        const chunk = agList.slice(i, i + agencyBatch);
        for (const ag of chunk) {
            out.write(`  MERGE INTO agency d USING (SELECT '${ag.ori}' AS o, ${escapeSQL(ag.agencyName)} AS n, ${escapeSQL(ag.state)} AS s, ${ag.pop} AS p, ${escapeSQL(ag.county)} AS c FROM dual) src ` +
                      `ON (d.ori_code = src.o) WHEN NOT MATCHED THEN INSERT (ori_code, agency_name, state_name, population, county) VALUES (src.o, src.n, src.s, src.p, src.c);\n`);
        }
        out.write('  COMMIT;\nEND;\n/\n\n');
    }

    // 3. Incidents + Persons + Involvements in PL/SQL batches
    out.write('-- ----------------------------------------------------------------------------\n');
    out.write(`-- Vorfaelle, Personen und Beteiligungen (${incidents.length} Vorfaelle)\n`);
    out.write('-- ----------------------------------------------------------------------------\n');
    
    const batchSize = 250;
    for (let b = 0; b < incidents.length; b += batchSize) {
        const chunk = incidents.slice(b, b + batchSize);
        out.write('DECLARE\n  v_inc NUMBER;\n  v_vic NUMBER;\n  v_off NUMBER;\nBEGIN\n');
        for (const inc of chunk) {
            const incDate = `DATE '${inc.year}-${String(inc.month).padStart(2, '0')}-01'`;
            out.write(`  INSERT INTO incident (ori_code, incident_year, incident_month, incident_number, situation, homicide_type, victim_count, offender_count, incident_date) ` +
                      `VALUES ('${inc.ori}', ${inc.year}, ${inc.month}, '${inc.incNum}', ${escapeSQL(inc.situation)}, ${escapeSQL(inc.homType)}, ${inc.vicCount}, ${inc.offCount}, ${incDate}) ` +
                      `RETURNING incident_id INTO v_inc;\n`);
            
            out.write(`  INSERT INTO person (age, sex, race, ethnicity) ` +
                      `VALUES (${inc.vicAge}, '${inc.vicSex}', '${inc.vicRace}', '${inc.vicEth}') ` +
                      `RETURNING person_id INTO v_vic;\n`);
            
            out.write(`  INSERT INTO victim_involvement (incident_id, person_id) VALUES (v_inc, v_vic);\n`);

            if (!inc.isUnknownOff) {
                out.write(`  INSERT INTO person (age, sex, race, ethnicity) ` +
                          `VALUES (${inc.offAge}, '${inc.offSex}', '${inc.offRace}', '${inc.offEth}') ` +
                          `RETURNING person_id INTO v_off;\n`);
                
                out.write(`  INSERT INTO offender_involvement (incident_id, person_id, victim_person_id, weapon_id, circumstance_id, relationship, offender_sequence) ` +
                          `VALUES (v_inc, v_off, v_vic, ${inc.weaponId}, ${inc.circId}, ${escapeSQL(inc.rel)}, 1);\n`);
            }
        }
        out.write('  COMMIT;\nEND;\n/\n\n');
        if ((b / batchSize) % 10 === 0) {
            console.log(`[${defaultYear}] Written ${b + chunk.length} / ${incidents.length}...`);
        }
    }

    out.write('SET FEEDBACK ON;\n');
    return new Promise(resolve => out.end(resolve));
}

async function main() {
    await convertFile('Decode/shr-1985.csv', 'sql/08_data_1985.sql', 1985);
    await convertFile('Decode/shr-2025.csv', 'sql/09_data_2025.sql', 2025);
    console.log('All datasets successfully generated!');
}

main().catch(console.error);

