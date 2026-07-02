const http = require('http');

async function waitForServer(maxRetries = 20, delay = 300) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await new Promise((resolve, reject) => {
        const r = http.get('http://127.0.0.1:3000/health', (res) => {
          res.resume();
          resolve(res.statusCode);
        });
        r.on('error', reject);
        r.setTimeout(500, () => { r.destroy(); reject(new Error('timeout')); });
      });
      return true;
    } catch (e) {
      await new Promise(r => setTimeout(r, delay));
    }
  }
  return false;
}

async function main() {
  process.stdout.write('Restarting server...');
  const { execSync } = require('child_process');
  try {
    execSync('Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force', { stdio: 'ignore' });
  } catch (e) { /* ok */ }
  await new Promise(r => setTimeout(r, 500));

  const child = require('child_process').spawn('node', ['index.js'], {
    stdio: ['ignore', 'pipe', 'pipe'],
    detached: false,
    env: { ...process.env, DOTENV_CONFIG_QUIET: 'true' },
  });
  child.stdout.on('data', () => {});
  child.stderr.on('data', () => {});

  const ready = await waitForServer();
  if (ready) {
    process.stdout.write(' OK\n');
  } else {
    process.stdout.write(' FAILED (timeout)\n');
    process.exit(1);
  }
}

main();
