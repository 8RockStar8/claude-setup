// Print each MCP server in mcp.json as "name<TAB>json" for `claude mcp add-json`.
// "${VAR}" placeholders are filled from the environment, so secrets never live
// in the repo. A server whose variables are not set prints "MISSING_ENV".
const fs = require('fs');

const servers = JSON.parse(fs.readFileSync(process.argv[2], 'utf8')).mcpServers || {};

for (const [name, config] of Object.entries(servers)) {
  let missing = false;
  const json = JSON.stringify(config).replace(/\$\{(\w+)\}/g, (_, key) => {
    if (process.env[key] === undefined) missing = true;
    return JSON.stringify(process.env[key] ?? '').slice(1, -1);
  });
  console.log(`${name}\t${missing ? 'MISSING_ENV' : json}`);
}
