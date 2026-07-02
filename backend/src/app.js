require('dotenv').config();
const Fastify = require('fastify');
const fastifyJwt = require('@fastify/jwt');
const fastifyCors = require('@fastify/cors');
const fastifySensible = require('@fastify/sensible');
const crypto = require('crypto');
const coreRoutes = require('./modules/core/routes');
const masterRoutes = require('./modules/master/routes');
const transactionRoutes = require('./modules/transaction/routes');
const inventoryRoutes = require('./modules/inventory/routes');
const crmRoutes = require('./modules/crm/routes');
const promotionRoutes = require('./modules/promotion/routes');
const systemRoutes = require('./modules/system/routes');

const knex = require('./db');
const uuidv7 = require('./helpers/uuidv7');

const app = Fastify({
  logger: {
    level: process.env.LOG_LEVEL || 'info',
    transport: {
      target: 'pino-pretty',
      options: { colorize: true },
    },
  },
});

app.register(fastifyCors, {
  origin: process.env.CORS_ORIGIN || '*',
});

app.register(fastifyJwt, {
  secret: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
  sign: { expiresIn: '15m' },
});

app.register(fastifySensible);

app.decorate('knex', knex);

async function checkUserActive(userId, userType) {
  if (userType === 'customer') {
    const customer = await knex('MstCustomer').where('CustomerID', userId).select('IsActive').first();
    return customer && customer.IsActive !== false;
  }
  const user = await knex('MstUser').where('UserID', userId).select('IsActive').first();
  return user && user.IsActive !== false;
}

app.decorate('authenticate', async function (request, reply) {
  try {
    await request.jwtVerify();
  } catch (err) {
    if (err.message === 'Authorization token expired') {
      throw { statusCode: 401, message: 'TokenExpired' };
    }
    throw { statusCode: 401, message: 'Unauthorized' };
  }

  const active = await checkUserActive(request.user.id, request.user.type || 'user');
  if (!active) {
    throw { statusCode: 401, message: 'AccountSuspended' };
  }
});

app.decorate('checkPermission', function (requiredPermissions = []) {
  return async (request, reply) => {
    try {
      await request.jwtVerify();
    } catch (err) {
      if (err.message === 'Authorization token expired') {
        throw { statusCode: 401, message: 'TokenExpired' };
      }
      throw { statusCode: 401, message: 'Unauthorized' };
    }

    const user = request.user;
    if (!user) {
      throw { statusCode: 401, message: 'User not found in token' };
    }

    const active = await checkUserActive(user.id, user.type || 'user');
    if (!active) {
      throw { statusCode: 401, message: 'AccountSuspended' };
    }

    if (requiredPermissions.length === 0) {
      return;
    }

    const userPermissions = await knex('RolePermission as rp')
      .join('MstPermission as mp', 'rp.PermissionID', 'mp.PermissionID')
      .where('rp.RoleID', user.roleId)
      .pluck('mp.PermissionName');

    const hasPermission = requiredPermissions.some((perm) =>
      userPermissions.includes(perm)
    );

    if (!hasPermission) {
      throw { statusCode: 403, message: 'Forbidden: Insufficient permissions' };
    }
  };
});

app.decorate('generateToken', function (user, type = 'user') {
  return app.jwt.sign({
    id: user.UserID || user.CustomerID,
    roleId: user.RoleID,
    branchId: user.BranchID,
    username: user.Username,
    type,
  });
});

app.decorate('generateRefreshToken', async function (userId, userType = 'Employee') {
  const token = crypto.randomBytes(48).toString('hex');
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
  await knex('RefreshToken').insert({
    RefreshTokenID: uuidv7(),
    UserID: userId,
    UserType: userType,
    Token: token,
    ExpiresAt: expiresAt,
  });
  return token;
});

app.post('/api/auth/refresh', async (request, reply) => {
  const { refreshToken } = request.body;
  if (!refreshToken) {
    return reply.status(400).send({ error: 'Refresh token required' });
  }

  const stored = await knex('RefreshToken')
    .where({ Token: refreshToken, IsRevoked: false })
    .where('ExpiresAt', '>', new Date())
    .first();

  if (!stored) {
    return reply.status(401).send({ error: 'RefreshTokenInvalid' });
  }

  const active = await checkUserActive(stored.UserID, stored.UserType);
  if (!active) {
    await knex('RefreshToken').where('RefreshTokenID', stored.RefreshTokenID).update({ IsRevoked: true });
    return reply.status(401).send({ error: 'AccountSuspended' });
  }

  let userData;
  if (stored.UserType === 'Customer') {
    userData = await knex('MstCustomer').where('CustomerID', stored.UserID).first();
    if (!userData) return reply.status(401).send({ error: 'User not found' });
    const newAccessToken = app.jwt.sign({
      id: userData.CustomerID,
      type: 'customer',
    });
    return { accessToken: newAccessToken };
  }

  userData = await knex('MstUser').where('UserID', stored.UserID).first();
  if (!userData) return reply.status(401).send({ error: 'User not found' });

  const newAccessToken = app.jwt.sign({
    id: userData.UserID,
    roleId: userData.RoleID,
    branchId: userData.BranchID,
    username: userData.Username,
    type: 'user',
  });

  return { accessToken: newAccessToken };
});

app.post('/api/auth/logout', async (request, reply) => {
  const { refreshToken } = request.body;
  if (refreshToken) {
    await knex('RefreshToken').where({ Token: refreshToken }).update({ IsRevoked: true });
  }
  return { message: 'Logged out' };
});

app.setErrorHandler((error, request, reply) => {
  const statusCode = error.statusCode || error.status || 500;
  const message = error.message || 'Internal Server Error';
  app.log.error({ statusCode, message, stack: error.stack });
  reply.code(statusCode).send({ error: message });
});

app.register(coreRoutes, { prefix: '/api' });
app.register(masterRoutes, { prefix: '/api' });
app.register(transactionRoutes, { prefix: '/api' });
app.register(inventoryRoutes, { prefix: '/api' });
app.register(crmRoutes, { prefix: '/api' });
app.register(promotionRoutes, { prefix: '/api' });
app.register(systemRoutes, { prefix: '/api' });

module.exports = app;
