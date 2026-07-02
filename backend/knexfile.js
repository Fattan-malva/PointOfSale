require('dotenv').config();

module.exports = {
  development: {
    client: 'mssql',
    connection: {
      server: process.env.DB_SERVER || 'localhost',
      port: parseInt(process.env.DB_PORT || '1433'),
      user: process.env.DB_USER || 'sa',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'pos_db',
      options: {
        encrypt: false,
        trustServerCertificate: true,
      },
    },
    migrations: {
      directory: './migrations',
      extension: 'js',
    },
    seeds: {
      directory: './seeds',
      extension: 'js',
    },
  },
  staging: {
    client: 'mssql',
    connection: {
      server: process.env.DB_SERVER,
      port: parseInt(process.env.DB_PORT || '1433'),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      options: {
        encrypt: true,
        trustServerCertificate: true,
      },
    },
    migrations: {
      directory: './migrations',
      extension: 'js',
    },
    seeds: {
      directory: './seeds',
      extension: 'js',
    },
  },
  production: {
    client: 'mssql',
    connection: {
      server: process.env.DB_SERVER,
      port: parseInt(process.env.DB_PORT || '1433'),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      options: {
        encrypt: true,
        trustServerCertificate: false,
      },
    },
    migrations: {
      directory: './migrations',
      extension: 'js',
    },
    seeds: {
      directory: './seeds',
      extension: 'js',
    },
    pool: {
      min: 2,
      max: 10,
    },
  },
};
