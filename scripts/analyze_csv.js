const fs = require('fs');
const readline = require('readline');

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

async function checkDupes(file) {
    const rl = readline.createInterface({ input: fs.createReadStream(file) });
    const keys = new Set();
    let dupes = 0;
    let count = 0;

    for await (const line of rl) {
        count++;
        if (count === 1) continue;
        const row = parseLine(line);
        if (row.length < 20) continue;
        const ori = row[2];
        const month = row[12];
        const incNum = row[16];
        const key = `${ori}_${month}_${incNum}`;
        if (keys.has(key)) {
            dupes++;
        } else {
            keys.add(key);
        }
    }
    console.log(`${file}: total=${count - 1}, unique keys=${keys.size}, dupes=${dupes}`);
}

(async () => {
    await checkDupes('Decode/shr-1985.csv');
    await checkDupes('Decode/shr-2025.csv');
})();
