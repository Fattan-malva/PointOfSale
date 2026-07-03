const ReportingService = require('./service');

async function reportingRoutes(fastify, opts) {
  const service = new ReportingService();

  fastify.get('/reports/sales', {
    preHandler: [fastify.checkPermission(['CanViewSales'])],
    handler: async (request, reply) => {
      const { DateFrom, DateTo, BranchID } = request.query;
      const report = await service.getSalesReport({ DateFrom, DateTo, BranchID });
      return { data: report };
    },
  });

  fastify.get('/reports/sales/by-payment', {
    preHandler: [fastify.checkPermission(['CanViewSales'])],
    handler: async (request, reply) => {
      const { DateFrom, DateTo, BranchID } = request.query;
      const report = await service.getSalesByPaymentMethod({ DateFrom, DateTo, BranchID });
      return { data: report };
    },
  });

  fastify.get('/reports/sales/by-cashier', {
    preHandler: [fastify.checkPermission(['CanViewSales'])],
    handler: async (request, reply) => {
      const { DateFrom, DateTo, BranchID } = request.query;
      const report = await service.getSalesByCashier({ DateFrom, DateTo, BranchID });
      return { data: report };
    },
  });

  fastify.get('/reports/sales/top-items', {
    preHandler: [fastify.checkPermission(['CanViewSales'])],
    handler: async (request, reply) => {
      const { DateFrom, DateTo, BranchID, Limit } = request.query;
      const report = await service.getTopSellingItems({ DateFrom, DateTo, BranchID, Limit: Limit ? parseInt(Limit) : 10 });
      return { data: report };
    },
  });

  fastify.get('/reports/stock', {
    preHandler: [fastify.checkPermission(['CanViewInventory'])],
    handler: async (request, reply) => {
      const { BranchID, LowStockThreshold } = request.query;
      const report = await service.getStockReport({ BranchID, LowStockThreshold: LowStockThreshold ? parseInt(LowStockThreshold) : 10 });
      return { data: report };
    },
  });

  fastify.get('/reports/shifts', {
    preHandler: [fastify.checkPermission(['CanManageShift'])],
    handler: async (request, reply) => {
      const { DateFrom, DateTo, BranchID } = request.query;
      const report = await service.getShiftReport({ DateFrom, DateTo, BranchID });
      return { data: report };
    },
  });

  fastify.get('/reports/dashboard', {
    preHandler: [fastify.checkPermission(['CanViewSales'])],
    handler: async (request, reply) => {
      const { BranchID } = request.query;
      const summary = await service.getDashboardSummary({ BranchID });
      return { data: summary };
    },
  });
}

module.exports = reportingRoutes;
