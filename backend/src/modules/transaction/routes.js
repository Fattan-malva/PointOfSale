const TransactionService = require('./service');

async function transactionRoutes(fastify, opts) {
  const service = new TransactionService();

  const idParam = {
    type: 'object',
    required: ['id'],
    properties: { id: { type: 'string', format: 'uuid' } },
  };

  fastify.get('/orders', {
    preHandler: [fastify.checkPermission(['CanViewOrder'])],
    handler: async (request, reply) => {
      const { BranchID, Status, PaymentStatus, OrderType, DateFrom, DateTo, limit, offset } = request.query;
      const filters = {
        BranchID, Status, PaymentStatus, OrderType, DateFrom, DateTo,
        limit: limit ? parseInt(limit) : undefined,
        offset: offset ? parseInt(offset) : undefined,
      };
      const [data, { total }] = await Promise.all([
        service.getAllOrders(filters),
        service.countAllOrders(filters),
      ]);
      return { data, total };
    },
  });

  fastify.get('/orders/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanViewOrder'])],
    handler: async (request, reply) => {
      const order = await service.getOrderWithDetails(request.params.id);
      return { data: order };
    },
  });

  fastify.post('/orders', {
    schema: {
      body: {
        type: 'object',
        required: ['BranchID', 'UserID', 'OrderType'],
        properties: {
          BranchID: { type: 'string', format: 'uuid' },
          UserID: { type: 'string', format: 'uuid' },
          CustomerID: { type: 'string', format: 'uuid' },
          TableID: { type: 'string', format: 'uuid' },
          OrderType: { type: 'string', enum: ['DineIn', 'TakeAway', 'Delivery'] },
          Note: { type: 'string' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanCreateOrder'])],
    handler: async (request, reply) => {
      const order = await service.createOrder({
        ...request.body,
        Status: 'Draft',
      });
      reply.code(201);
      return { data: order };
    },
  });

  fastify.put('/orders/:id', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        properties: {
          Note: { type: 'string' },
          OrderType: { type: 'string', enum: ['DineIn', 'TakeAway', 'Delivery'] },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanCreateOrder'])],
    handler: async (request, reply) => {
      const order = await service.updateOrder(request.params.id, request.body);
      return { data: order };
    },
  });

  fastify.post('/orders/:id/confirm', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanCreateOrder'])],
    handler: async (request, reply) => {
      const order = await service.confirmOrder(request.params.id);
      return { data: order };
    },
  });

  fastify.post('/orders/:id/complete', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanCreateOrder'])],
    handler: async (request, reply) => {
      const order = await service.completeOrder(request.params.id);
      return { data: order };
    },
  });

  fastify.post('/orders/:id/cancel', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanCancelOrder'])],
    handler: async (request, reply) => {
      const order = await service.cancelOrder(request.params.id);
      return { data: order };
    },
  });

  fastify.post('/orders/:id/items', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        required: ['ItemID'],
        properties: {
          ItemID: { type: 'string', format: 'uuid' },
          Qty: { type: 'number', minimum: 0.5 },
          Note: { type: 'string' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanCreateOrder'])],
    handler: async (request, reply) => {
      const detail = await service.addItemToOrder(request.params.id, request.body);
      reply.code(201);
      return { data: detail };
    },
  });

  fastify.put('/orders/:id/items/:detailId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'detailId'],
        properties: { id: { type: 'string', format: 'uuid' }, detailId: { type: 'string', format: 'uuid' } },
      },
      body: {
        type: 'object',
        properties: {
          Qty: { type: 'number', minimum: 0.5 },
          Note: { type: 'string' },
          Price: { type: 'number', minimum: 0 },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanCreateOrder', 'CanEditPrice'])],
    handler: async (request, reply) => {
      const detail = await service.updateOrderItem(request.params.id, request.params.detailId, request.body);
      return { data: detail };
    },
  });

  fastify.delete('/orders/:id/items/:detailId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'detailId'],
        properties: { id: { type: 'string', format: 'uuid' }, detailId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanCreateOrder'])],
    handler: async (request, reply) => {
      await service.removeItemFromOrder(request.params.id, request.params.detailId);
      return { message: 'Item removed' };
    },
  });

  fastify.post('/orders/:id/items/:detailId/modifiers', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'detailId'],
        properties: { id: { type: 'string', format: 'uuid' }, detailId: { type: 'string', format: 'uuid' } },
      },
      body: {
        type: 'object',
        required: ['OptionName'],
        properties: {
          ModifierID: { type: 'string', format: 'uuid' },
          ModifierOptionID: { type: 'string', format: 'uuid' },
          OptionName: { type: 'string', minLength: 1 },
          AdditionalPrice: { type: 'number', minimum: 0 },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanCreateOrder'])],
    handler: async (request, reply) => {
      const modifier = await service.addModifierToItem(request.params.id, request.params.detailId, request.body);
      reply.code(201);
      return { data: modifier };
    },
  });

  fastify.delete('/orders/:id/items/:detailId/modifiers/:modifierId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'detailId', 'modifierId'],
        properties: {
          id: { type: 'string', format: 'uuid' },
          detailId: { type: 'string', format: 'uuid' },
          modifierId: { type: 'string', format: 'uuid' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanCreateOrder'])],
    handler: async (request, reply) => {
      await service.removeModifierFromItem(request.params.id, request.params.detailId, request.params.modifierId);
      return { message: 'Modifier removed' };
    },
  });

  fastify.post('/orders/:id/discounts', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        required: ['DiscountName', 'DiscountType', 'DiscountValue', 'DiscountAmount'],
        properties: {
          DiscountID: { type: 'string', format: 'uuid' },
          DiscountName: { type: 'string', minLength: 1 },
          DiscountType: { type: 'string', enum: ['Percentage', 'Nominal'] },
          DiscountValue: { type: 'number', minimum: 0 },
          DiscountAmount: { type: 'number', minimum: 0 },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanCreateOrder'])],
    handler: async (request, reply) => {
      const discount = await service.applyDiscount(request.params.id, request.body);
      reply.code(201);
      return { data: discount };
    },
  });

  fastify.delete('/orders/:id/discounts/:discountId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'discountId'],
        properties: { id: { type: 'string', format: 'uuid' }, discountId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanCreateOrder'])],
    handler: async (request, reply) => {
      await service.removeDiscount(request.params.id, request.params.discountId);
      return { message: 'Discount removed' };
    },
  });

  fastify.post('/orders/:id/payments', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        required: ['PaymentMethodID', 'PaymentAmount'],
        properties: {
          PaymentMethodID: { type: 'string', format: 'uuid' },
          PaymentAmount: { type: 'number', minimum: 0 },
          ReferenceNumber: { type: 'string', maxLength: 100 },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePayment'])],
    handler: async (request, reply) => {
      const payment = await service.processPayment(request.params.id, request.body);
      reply.code(201);
      return { data: payment };
    },
  });

  fastify.get('/kitchen', {
    preHandler: [fastify.checkPermission(['CanViewOrder'])],
    handler: async (request, reply) => {
      const orders = await service.getKitchenOrders();
      return { data: orders };
    },
  });

  fastify.get('/orders/:id/kitchen', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanViewOrder'])],
    handler: async (request, reply) => {
      const items = await service.getKitchenByOrderId(request.params.id);
      return { data: items };
    },
  });

  fastify.put('/kitchen/:id/status', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        required: ['Status'],
        properties: {
          Status: { type: 'string', enum: ['Pending', 'Preparing', 'Done', 'Cancelled'] },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanViewOrder'])],
    handler: async (request, reply) => {
      const item = await service.updateKitchenItemStatus(request.params.id, request.body.Status);
      return { data: item };
    },
  });

  fastify.get('/shift-closings', {
    preHandler: [fastify.checkPermission(['CanManageShift'])],
    handler: async (request, reply) => {
      const { BranchID, limit, offset } = request.query;
      const shifts = await service.getAllShiftClosing({
        BranchID,
        limit: limit ? parseInt(limit) : undefined,
        offset: offset ? parseInt(offset) : undefined,
      });
      return { data: shifts };
    },
  });

  fastify.get('/shift-closings/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageShift'])],
    handler: async (request, reply) => {
      const shift = await service.getShiftClosingById(request.params.id);
      return { data: shift };
    },
  });

  fastify.post('/shift-closings', {
    schema: {
      body: {
        type: 'object',
        required: ['BranchID', 'UserID', 'ShiftID'],
        properties: {
          BranchID: { type: 'string', format: 'uuid' },
          UserID: { type: 'string', format: 'uuid' },
          ShiftID: { type: 'string', format: 'uuid' },
          OpeningBalance: { type: 'number', minimum: 0 },
          Note: { type: 'string' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageShift'])],
    handler: async (request, reply) => {
      const shift = await service.openShift(request.body);
      reply.code(201);
      return { data: shift };
    },
  });

  fastify.put('/shift-closings/:id/close', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        properties: {
          ClosingBalance: { type: 'number', minimum: 0 },
          TotalCash: { type: 'number', minimum: 0 },
          TotalCard: { type: 'number', minimum: 0 },
          TotalEwallet: { type: 'number', minimum: 0 },
          TotalQR: { type: 'number', minimum: 0 },
          Note: { type: 'string' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageShift'])],
    handler: async (request, reply) => {
      const shift = await service.closeShift(request.params.id, request.body);
      return { data: shift };
    },
  });

  fastify.get('/sales/summary', {
    preHandler: [fastify.checkPermission(['CanViewSales'])],
    handler: async (request, reply) => {
      const { Date: date, BranchID } = request.query;
      const targetDate = date || new Date().toISOString().split('T')[0];
      const summary = await service.getSalesSummary(targetDate, BranchID);
      return { data: summary };
    },
  });
}

module.exports = transactionRoutes;
