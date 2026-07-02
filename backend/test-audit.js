const fs = require('fs');

function findMissingAuth(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');
  let routes = [];
  let current = null;

  for (let i = 0; i < lines.length; i++) {
    const l = lines[i];
    const m = l.match(/fastify\.(get|post|put|delete)\('([^']+)'/);
    if (m) {
      if (current) routes.push(current);
      current = { method: m[1], path: m[2], line: i + 1, hasAuth: false, hasPerm: false };
    }
    if (current && l.includes('preHandler')) {
      if (l.includes('authenticate')) current.hasAuth = true;
      if (l.includes('checkPermission')) current.hasPerm = true;
    }
  }
  if (current) routes.push(current);

  const missing = routes.filter(r => r.method === 'get' && !r.hasAuth && !r.hasPerm);
  return missing;
}

const files = [
  'src/modules/master/routes.js',
  'src/modules/core/routes.js',
  'src/modules/transaction/routes.js',
  'src/modules/inventory/routes.js',
  'src/modules/promotion/routes.js',
  'src/modules/system/routes.js',
];

for (const f of files) {
  const missing = findMissingAuth(f);
  if (missing.length > 0) {
    console.log(f + ':');
    for (const r of missing) console.log('  Line ' + r.line + ': ' + r.method + ' ' + r.path);
  } else {
    console.log(f + ': OK');
  }
}
