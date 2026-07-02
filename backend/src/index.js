const app = require('./app');
const db = require('./db');

const PORT = process.env.PORT || 3000;

async function start() {
  try {
    await db.raw('SELECT 1');
    app.log.info('Database connected');
    await app.listen({ port: PORT, host: '0.0.0.0' });
    app.log.info(`Server listening on port ${PORT}`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

start();

module.exports = app;
