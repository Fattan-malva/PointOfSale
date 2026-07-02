const SystemService = require('./service');

async function systemRoutes(fastify, opts) {
  const service = new SystemService();

  fastify.get('/audit-logs', {
    preHandler: [fastify.checkPermission(['CanViewAuditLog'])],
    handler: async (request, reply) => {
      const { Module, Action, UserID, TableName, RecordID, DateFrom, DateTo } = request.query;
      const logs = await service.getAuditLogs({ Module, Action, UserID, TableName, RecordID, DateFrom, DateTo });
      return { data: logs };
    },
  });

  fastify.get('/user-activities', {
    preHandler: [fastify.checkPermission(['CanViewActivityLog'])],
    handler: async (request, reply) => {
      const { UserID, Action, UserType, DateFrom, DateTo } = request.query;
      const activities = await service.getUserActivities({ UserID, Action, UserType, DateFrom, DateTo });
      return { data: activities };
    },
  });
}

module.exports = systemRoutes;
