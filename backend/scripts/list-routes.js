require('dotenv').config();
const http = require('http');

const HOST = process.env.API_HOST || 'localhost';
const PORT = process.env.PORT || 3000;
const USER = process.env.API_USER || 'admin';
const PASS = process.env.API_PASS || 'admin123';

function request(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const opts = {
      hostname: HOST,
      port: PORT,
      path,
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (token) opts.headers['Authorization'] = 'Bearer ' + token;

    const req = http.request(opts, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(data) });
        } catch {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function main() {
  console.log('\nConnecting to http://' + HOST + ':' + PORT + '...\n');

  let result = await request('POST', '/api/auth/user/login', { Username: USER, Password: PASS });
  if (result.status !== 200) {
    console.log('Login failed (status ' + result.status + ').');
    console.log('Make sure the server is running and credentials are correct.');
    console.log('Set API_USER / API_PASS / API_HOST env vars if different.\n');
    process.exit(1);
  }

  const token = result.body.data.accessToken;

  result = await request('GET', '/api/system/routes', null, token);
  if (result.status !== 200) {
    console.log('Failed to fetch routes (status ' + result.status + ').\n');
    process.exit(1);
  }

  const routes = result.body.data;

  const methodW = 10;
  const authW = 22;
  const permW = 44;
  const sep = '-'.repeat(140);

  console.log('  Method' + ' '.repeat(methodW - 6) +
              'Auth' + ' '.repeat(authW - 4) +
              'Permissions' + ' '.repeat(permW - 11) +
              'URL');
  console.log('  ' + sep);

  let lastModule = '';
  for (const r of routes) {
    const moduleName = r.url.split('/')[2] || '';
    if (moduleName && moduleName !== lastModule) {
      lastModule = moduleName;
      console.log();
    }
    const method = r.method.padEnd(methodW);
    const auth = r.authType.padEnd(authW);
    const perms = (r.permissions && r.permissions.length ? r.permissions.join(', ') : '-').padEnd(permW);
    console.log('  ' + method + auth + perms + r.url);
  }

  console.log('\n  Total: ' + routes.length + ' routes\n');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
