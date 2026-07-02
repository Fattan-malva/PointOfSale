require('dotenv').config();
const app = require('./src/app');
const db = require('./src/db');

app.get('/health', async (request, reply) => {
  try {
    await db.raw('SELECT 1');
    return { status: 'ok', database: 'connected' };
  } catch (error) {
    reply.code(503);
    return { status: 'error', database: 'disconnected', error: error.message };
  }
});

const start = async () => {
  try {
    const port = process.env.PORT || 3000;
    const host = process.env.HOST || '0.0.0.0';
    await app.listen({ port, host });
    app.log.info(`Server running on http://${host}:${port}`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
};

start();
