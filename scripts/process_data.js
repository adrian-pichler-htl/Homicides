const fs = require('fs');
const readline = require('readline');
const path = require('path');

function parseCSVLine(text) {
    const p = [];
    let cur = '';
    let inQuotes = false;
    for (let i = 0; i < text.length; i++) {
        const c = text[i];
        if (c === '"') {
            inQuotes = !inQuotes;
        } else if (c === ',' && !inQuotes) {
            p.push(cur.trim());
            cur = '';
        } else {
            cur += c;
        }
    }
    p.push(cur.trim());
    return p;
}

async function testParse() {
    const csvPath = path.join(__dirname, '..', 'Decode', 'shr-2025.csv');
    const fileStream = fs.createReadStream(csvPath);
    const rl = readline.createInterface({ input: fileStream, crlfDelay: Infinity });

    let count = 0;
    for await (const line of rl) {
        count++;
        if (count <= 10) {
            const row = parseCSVLine(line);
            if (count === 1) {
                console.log(`Header length: ${row.length}`);
            } else {
                console.log(`Row ${count}: ORI=${row[2]}, Agency=${row[10]}, State=${row[11]}, Year=${row[5]}, Month=${row[12]}, Sit=${row[17]}, VicAge=${row[18]}, OffAge=${row[22]}, OffWeapon=${row[26]}, Rel=${row[27]}`);
            }
        } else {
            break;
        }
    }
    console.log('Sample parsed successfully.');
}

testParse().catch(console.error);

