const CoreService = require('./service');
const { userActivity } = require('../../helpers/audit');

async function coreRoutes(fastify, opts) {
  const service = new CoreService();

  const idParam = {
    type: 'object',
    required: ['id'],
    properties: { id: { type: 'string', format: 'uuid' } },
  };

  // ==================== Branch ====================
  fastify.get('/branches', {
    preHandler: [fastify.checkPermission([])],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllBranch({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllBranch(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/branches/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission([])],
    handler: async (request, reply) => {
      const branch = await service.getBranchById(request.params.id);
      return { data: branch };
    },
  });

  fastify.post('/branches', {
    schema: {
      body: {
        type: 'object',
        required: ['BranchCode', 'BranchName'],
        properties: {
          BranchCode: { type: 'string', minLength: 2, maxLength: 20 },
          BranchName: { type: 'string', minLength: 2, maxLength: 100 },
          Address: { type: 'string', maxLength: 255 },
          Phone: { type: 'string', maxLength: 20 },
          Email: { type: 'string', maxLength: 100 },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageBranch'])],
    handler: async (request, reply) => {
      const branch = await service.createBranch(request.body);
      reply.code(201);
      return { data: branch };
    },
  });

  fastify.put('/branches/:id', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        properties: {
          BranchCode: { type: 'string', minLength: 2, maxLength: 20 },
          BranchName: { type: 'string', minLength: 2, maxLength: 100 },
          Address: { type: 'string', maxLength: 255 },
          Phone: { type: 'string', maxLength: 20 },
          Email: { type: 'string', maxLength: 100 },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageBranch'])],
    handler: async (request, reply) => {
      const branch = await service.updateBranch(request.params.id, request.body);
      return { data: branch };
    },
  });

  fastify.delete('/branches/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageBranch'])],
    handler: async (request, reply) => {
      await service.deleteBranch(request.params.id);
      return { message: 'Branch deleted' };
    },
  });

  // ==================== Role ====================
  fastify.get('/roles', {
    preHandler: [fastify.checkPermission([])],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllRole({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllRole(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/roles/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission([])],
    handler: async (request, reply) => {
      const role = await service.getRoleById(request.params.id);
      return { data: role };
    },
  });

  fastify.post('/roles', {
    schema: {
      body: {
        type: 'object',
        required: ['RoleName'],
        properties: {
          RoleName: { type: 'string', minLength: 2, maxLength: 50 },
          Description: { type: 'string' },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageRolePermission'])],
    handler: async (request, reply) => {
      const role = await service.createRole(request.body);
      reply.code(201);
      return { data: role };
    },
  });

  fastify.put('/roles/:id', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        properties: {
          RoleName: { type: 'string', minLength: 2, maxLength: 50 },
          Description: { type: 'string' },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageRolePermission'])],
    handler: async (request, reply) => {
      const role = await service.updateRole(request.params.id, request.body);
      return { data: role };
    },
  });

  fastify.delete('/roles/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageRolePermission'])],
    handler: async (request, reply) => {
      await service.deleteRole(request.params.id);
      return { message: 'Role deleted' };
    },
  });

  // ==================== Permission ====================
  fastify.get('/permissions', {
    preHandler: [fastify.checkPermission([])],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllPermission({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllPermission(),
      ]);
      return { data, total };
    },
  });

  fastify.post('/permissions', {
    schema: {
      body: {
        type: 'object',
        required: ['PermissionName'],
        properties: {
          PermissionName: { type: 'string', minLength: 2, maxLength: 100 },
          Description: { type: 'string' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageRolePermission'])],
    handler: async (request, reply) => {
      const perm = await service.createPermission(request.body);
      reply.code(201);
      return { data: perm };
    },
  });

  fastify.delete('/permissions/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageRolePermission'])],
    handler: async (request, reply) => {
      await service.deletePermission(request.params.id);
      return { message: 'Permission deleted' };
    },
  });

  // ==================== Role-Permission ====================
  fastify.get('/roles/:id/permissions', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageRolePermission'])],
    handler: async (request, reply) => {
      const permissions = await service.getPermissionsByRoleId(request.params.id);
      return { data: permissions };
    },
  });

  fastify.post('/roles/:roleId/permissions/:permissionId', {
    schema: {
      params: {
        type: 'object',
        required: ['roleId', 'permissionId'],
        properties: { roleId: { type: 'string', format: 'uuid' }, permissionId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageRolePermission'])],
    handler: async (request, reply) => {
      await service.assignPermission(request.params.roleId, request.params.permissionId);
      reply.code(201);
      return { message: 'Permission assigned' };
    },
  });

  fastify.delete('/roles/:roleId/permissions/:permissionId', {
    schema: {
      params: {
        type: 'object',
        required: ['roleId', 'permissionId'],
        properties: { roleId: { type: 'string', format: 'uuid' }, permissionId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageRolePermission'])],
    handler: async (request, reply) => {
      await service.removePermission(request.params.roleId, request.params.permissionId);
      return { message: 'Permission removed' };
    },
  });

  // ==================== User ====================
  fastify.get('/users', {
    preHandler: [fastify.checkPermission(['CanManageEmployee'])],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllUser({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllUser(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/users/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageEmployee'])],
    handler: async (request, reply) => {
      const user = await service.getUserById(request.params.id);
      return { data: user };
    },
  });

  fastify.post('/users', {
    schema: {
      body: {
        type: 'object',
        required: ['BranchID', 'RoleID', 'Username', 'PasswordHash', 'FullName'],
        properties: {
          BranchID: { type: 'string', format: 'uuid' },
          RoleID: { type: 'string', format: 'uuid' },
          Username: { type: 'string', minLength: 3, maxLength: 50 },
          PasswordHash: { type: 'string', minLength: 6 },
          FullName: { type: 'string', minLength: 2, maxLength: 100 },
          Phone: { type: 'string', maxLength: 20 },
          Email: { type: 'string', maxLength: 100 },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageEmployee'])],
    handler: async (request, reply) => {
      const user = await service.createUser(request.body);
      reply.code(201);
      return { data: user };
    },
  });

  fastify.put('/users/:id', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        properties: {
          RoleID: { type: 'string', format: 'uuid' },
          Username: { type: 'string', minLength: 3, maxLength: 50 },
          PasswordHash: { type: 'string', minLength: 6 },
          FullName: { type: 'string', minLength: 2, maxLength: 100 },
          Phone: { type: 'string', maxLength: 20 },
          Email: { type: 'string', maxLength: 100 },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageEmployee'])],
    handler: async (request, reply) => {
      const user = await service.updateUser(request.params.id, request.body);
      return { data: user };
    },
  });

  fastify.delete('/users/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageEmployee'])],
    handler: async (request, reply) => {
      await service.deleteUser(request.params.id);
      return { message: 'User deleted' };
    },
  });

  // ==================== Auth ====================
  fastify.post('/auth/user/login', {
    config: {
      rateLimit: {
        max: 10,
        timeWindow: '1 minute',
      },
    },
    schema: {
      body: {
        type: 'object',
        required: ['Username', 'Password'],
        properties: {
          Username: { type: 'string' },
          Password: { type: 'string' },
        },
      },
    },
    handler: async (request, reply) => {
      const { Username, Password } = request.body;
      const user = await service.loginUser(Username, Password);
      const accessToken = fastify.generateToken(user);
      const refreshToken = await fastify.generateRefreshToken(user.UserID, 'Employee');

      await fastify.knex('MstUser')
        .where('UserID', user.UserID)
        .update({ LastLoginAt: fastify.knex.fn.now() });

      await userActivity({
        UserID: user.UserID,
        UserType: 'Employee',
        Action: 'Login',
        Device: request.headers['user-agent'],
        IPAddress: request.ip,
      });

      return {
        data: {
          accessToken,
          refreshToken,
          user: {
            UserID: user.UserID,
            FullName: user.FullName,
            Username: user.Username,
            RoleID: user.RoleID,
            RoleName: user.RoleName,
            BranchID: user.BranchID,
            BranchName: user.BranchName,
          },
        },
      };
    },
  });

  // ==================== AppConfig ====================
  fastify.get('/app-config', {
    handler: async (request, reply) => {
      const config = await service.getAppConfig();
      return { data: config };
    },
  });

  fastify.put('/app-config', {
    preHandler: [fastify.checkPermission(['CanManageAppConfig'])],
    handler: async (request, reply) => {
      const config = await service.updateAppConfig(request.body);
      return { data: config };
    },
  });
}

module.exports = coreRoutes;
