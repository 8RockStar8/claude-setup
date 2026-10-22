// Deep-merge the repo's settings.json into the user's ~/.claude/settings.json.
// Objects merge recursively, arrays are unioned, repo values win for scalars.
// Prints "changed" or "unchanged".
const fs = require('fs');

const [src, dest] = process.argv.slice(2);

const readJson = (file, fallback) => {
  if (!fs.existsSync(file)) return fallback;
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (err) {
    console.error(`${file} is not valid JSON, not touching it (${err.message})`);
    process.exit(1);
  }
};

const isObject = (v) => v !== null && typeof v === 'object' && !Array.isArray(v);

const merge = (base, extra) => {
  if (Array.isArray(base) && Array.isArray(extra)) {
    const seen = new Set(base.map((v) => JSON.stringify(v)));
    return [...base, ...extra.filter((v) => !seen.has(JSON.stringify(v)))];
  }
  if (isObject(base) && isObject(extra)) {
    const out = { ...base };
    for (const key of Object.keys(extra)) {
      out[key] = key in base ? merge(base[key], extra[key]) : extra[key];
    }
    return out;
  }
  return extra;
};

const current = readJson(dest, {});
const merged = merge(current, readJson(src, {}));

if (JSON.stringify(current) === JSON.stringify(merged)) {
  console.log('unchanged');
} else {
  fs.writeFileSync(dest, JSON.stringify(merged, null, 2) + '\n');
  console.log('changed');
}
