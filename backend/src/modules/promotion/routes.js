const PromotionService = require('./service');

async function promotionRoutes(fastify, opts) {
  const service = new PromotionService();

  const idParam = {
    type: 'object',
    required: ['id'],
    properties: { id: { type: 'string', format: 'uuid' } },
  };

  fastify.get('/promotions', {
    preHandler: [fastify.checkPermission(['CanManagePromotion'])],
    handler: async (request, reply) => {
      const { IsActive, PromotionType } = request.query;
      const filter = {};
      if (IsActive !== undefined) filter.IsActive = IsActive === 'true';
      if (PromotionType) filter.PromotionType = PromotionType;
      return { data: await service.getAll(filter) };
    },
  });

  fastify.get('/promotions/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManagePromotion'])],
    handler: async (request, reply) => {
      return { data: await service.getById(request.params.id) };
    },
  });

  fastify.post('/promotions', {
    schema: {
      body: {
        type: 'object',
        required: ['PromotionName', 'PromotionType', 'StartDate'],
        properties: {
          PromotionName: { type: 'string', minLength: 2, maxLength: 100 },
          Description: { type: 'string' },
          StartDate: { type: 'string', format: 'date-time' },
          EndDate: { type: 'string', format: 'date-time' },
          MinimumPurchase: { type: 'number', minimum: 0 },
          MaximumDiscount: { type: 'number', minimum: 0 },
          PromotionType: { type: 'string', enum: ['Discount', 'BuyXGetY', 'HappyHour', 'Cashback'] },
          DiscountType: { type: 'string', enum: ['Percentage', 'Nominal'] },
          DiscountValue: { type: 'number', minimum: 0 },
          BuyQty: { type: 'integer', minimum: 1 },
          FreeQty: { type: 'integer', minimum: 1 },
          Priority: { type: 'integer' },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePromotion'])],
    handler: async (request, reply) => {
      const result = await service.create(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/promotions/:id', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        properties: {
          PromotionName: { type: 'string', minLength: 2, maxLength: 100 },
          Description: { type: 'string' },
          StartDate: { type: 'string', format: 'date-time' },
          EndDate: { type: 'string', format: 'date-time' },
          MinimumPurchase: { type: 'number', minimum: 0 },
          MaximumDiscount: { type: 'number', minimum: 0 },
          PromotionType: { type: 'string', enum: ['Discount', 'BuyXGetY', 'HappyHour', 'Cashback'] },
          DiscountType: { type: 'string', enum: ['Percentage', 'Nominal'] },
          DiscountValue: { type: 'number', minimum: 0 },
          BuyQty: { type: 'integer', minimum: 1 },
          FreeQty: { type: 'integer', minimum: 1 },
          Priority: { type: 'integer' },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePromotion'])],
    handler: async (request, reply) => {
      return { data: await service.update(request.params.id, request.body) };
    },
  });

  fastify.delete('/promotions/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManagePromotion'])],
    handler: async (request, reply) => {
      await service.delete(request.params.id);
      return { message: 'Promotion deleted' };
    },
  });

  fastify.get('/promotions/:id/items', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManagePromotion'])],
    handler: async (request, reply) => {
      return { data: await service.getItems(request.params.id) };
    },
  });

  fastify.post('/promotions/:id/items/:itemId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'itemId'],
        properties: { id: { type: 'string', format: 'uuid' }, itemId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePromotion'])],
    handler: async (request, reply) => {
      const result = await service.addItem(request.params.id, request.params.itemId);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.delete('/promotions/:id/items/:itemId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'itemId'],
        properties: { id: { type: 'string', format: 'uuid' }, itemId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePromotion'])],
    handler: async (request, reply) => {
      await service.removeItem(request.params.id, request.params.itemId);
      return { message: 'Item removed from promotion' };
    },
  });
}

module.exports = promotionRoutes;
