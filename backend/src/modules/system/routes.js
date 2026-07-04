const SystemService = require('./service');

async function systemRoutes(fastify, opts) {
  const service = new SystemService();

  fastify.get('/audit-logs', {
    preHandler: [fastify.checkPermission(['CanViewAuditLog'])],
    handler: async (request, reply) => {
      const { Module, Action, UserID, TableName, RecordID, DateFrom, DateTo, limit, offset } = request.query;
      const filters = {
        Module, Action, UserID, TableName, RecordID, DateFrom, DateTo,
        limit: limit ? parseInt(limit) : undefined,
        offset: offset ? parseInt(offset) : undefined,
      };
      const [data, { total }] = await Promise.all([
        service.getAuditLogs(filters),
        service.countAuditLogs(filters),
      ]);
      return { data, total };
    },
  });

  fastify.get('/user-activities', {
    preHandler: [fastify.checkPermission(['CanViewActivityLog'])],
    handler: async (request, reply) => {
      const { UserID, Action, UserType, DateFrom, DateTo, limit, offset } = request.query;
      const filters = {
        UserID, Action, UserType, DateFrom, DateTo,
        limit: limit ? parseInt(limit) : undefined,
        offset: offset ? parseInt(offset) : undefined,
      };
      const [data, { total }] = await Promise.all([
        service.getUserActivities(filters),
        service.countUserActivities(filters),
      ]);
      return { data, total };
    },
  });
}

module.exports = systemRoutes;
