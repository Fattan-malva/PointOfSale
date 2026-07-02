const InventoryService = require('./service');

async function inventoryRoutes(fastify, opts) {
  const service = new InventoryService();

  const idParam = {
    type: 'object',
    required: ['id'],
    properties: { id: { type: 'string', format: 'uuid' } },
  };

  fastify.get('/suppliers', {
    preHandler: [fastify.checkPermission(['CanManageSupplier'])],
    handler: async (request, reply) => {
      return { data: await service.getAllSupplier() };
    },
  });

  fastify.get('/suppliers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageSupplier'])],
    handler: async (request, reply) => {
      return { data: await service.getSupplierById(request.params.id) };
    },
  });

  fastify.post('/suppliers', {
    schema: {
      body: {
        type: 'object',
        required: ['SupplierCode', 'SupplierName'],
        properties: {
          SupplierCode: { type: 'string', minLength: 1, maxLength: 20 },
          SupplierName: { type: 'string', minLength: 2, maxLength: 100 },
          ContactPerson: { type: 'string', maxLength: 100 },
          Phone: { type: 'string', maxLength: 20 },
          Email: { type: 'string', maxLength: 100 },
          Address: { type: 'string' },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageSupplier'])],
    handler: async (request, reply) => {
      const result = await service.createSupplier(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/suppliers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageSupplier'])],
    handler: async (request, reply) => {
      return { data: await service.updateSupplier(request.params.id, request.body) };
    },
  });

  fastify.delete('/suppliers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageSupplier'])],
    handler: async (request, reply) => {
      await service.deleteSupplier(request.params.id);
      return { message: 'Supplier deleted' };
    },
  });

  fastify.get('/purchases', {
    preHandler: [fastify.checkPermission(['CanManagePurchase'])],
    handler: async (request, reply) => {
      const { Status, BranchID } = request.query;
      return { data: await service.getAllPurchase({ Status, BranchID }) };
    },
  });

  fastify.get('/purchases/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManagePurchase'])],
    handler: async (request, reply) => {
      return { data: await service.getPurchaseWithDetails(request.params.id) };
    },
  });

  fastify.post('/purchases', {
    schema: {
      body: {
        type: 'object',
        required: ['BranchID'],
        properties: {
          BranchID: { type: 'string', format: 'uuid' },
          SupplierID: { type: 'string', format: 'uuid' },
          Note: { type: 'string' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePurchase'])],
    handler: async (request, reply) => {
      const result = await service.createPurchase({ ...request.body, Status: 'Draft' });
      reply.code(201);
      return { data: result };
    },
  });

  fastify.post('/purchases/:id/receive', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManagePurchase'])],
    handler: async (request, reply) => {
      const result = await service.receivePurchase(request.params.id);
      return { data: result };
    },
  });

  fastify.post('/purchases/:id/items', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        required: ['ItemID', 'Qty', 'UnitCost'],
        properties: {
          ItemID: { type: 'string', format: 'uuid' },
          Qty: { type: 'number', minimum: 0 },
          UnitCost: { type: 'number', minimum: 0 },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePurchase'])],
    handler: async (request, reply) => {
      const result = await service.addItemToPurchase(request.params.id, request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.delete('/purchases/:id/items/:detailId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'detailId'],
        properties: { id: { type: 'string', format: 'uuid' }, detailId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePurchase'])],
    handler: async (request, reply) => {
      await service.removeItemFromPurchase(request.params.id, request.params.detailId);
      return { message: 'Item removed from purchase' };
    },
  });

  fastify.get('/stock', {
    preHandler: [fastify.checkPermission(['CanManageStock'])],
    handler: async (request, reply) => {
      const { BranchID, LowStock } = request.query;
      return { data: await service.getAllStock({ BranchID, LowStock }) };
    },
  });

  fastify.put('/stock/adjust', {
    schema: {
      body: {
        type: 'object',
        required: ['ItemID', 'BranchID', 'NewStock'],
        properties: {
          ItemID: { type: 'string', format: 'uuid' },
          BranchID: { type: 'string', format: 'uuid' },
          NewStock: { type: 'number', minimum: 0 },
          Note: { type: 'string' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageStock'])],
    handler: async (request, reply) => {
      const result = await service.adjustStock(request.body);
      return { data: result };
    },
  });

  fastify.get('/stock-movements', {
    preHandler: [fastify.checkPermission(['CanManageStock'])],
    handler: async (request, reply) => {
      const { ItemID, BranchID, Type } = request.query;
      return { data: await service.getStockMovements({ ItemID, BranchID, Type }) };
    },
  });

  fastify.get('/recipes', {
    preHandler: [fastify.checkPermission(['CanManageRecipe'])],
    handler: async (request, reply) => {
      return { data: await service.getAllRecipe() };
    },
  });

  fastify.get('/recipes/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageRecipe'])],
    handler: async (request, reply) => {
      return { data: await service.getRecipeWithDetails(request.params.id) };
    },
  });

  fastify.post('/recipes', {
    schema: {
      body: {
        type: 'object',
        required: ['ItemID', 'RecipeName'],
        properties: {
          ItemID: { type: 'string', format: 'uuid' },
          RecipeName: { type: 'string', minLength: 2, maxLength: 100 },
          Yield: { type: 'number', minimum: 0 },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageRecipe'])],
    handler: async (request, reply) => {
      const result = await service.createRecipe(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/recipes/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageRecipe'])],
    handler: async (request, reply) => {
      return { data: await service.updateRecipe(request.params.id, request.body) };
    },
  });

  fastify.delete('/recipes/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageRecipe'])],
    handler: async (request, reply) => {
      await service.deleteRecipe(request.params.id);
      return { message: 'Recipe deleted' };
    },
  });

  fastify.post('/recipes/:id/ingredients', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        required: ['ItemID', 'Qty'],
        properties: {
          ItemID: { type: 'string', format: 'uuid' },
          Qty: { type: 'number', minimum: 0 },
          Unit: { type: 'string', maxLength: 20 },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageRecipe'])],
    handler: async (request, reply) => {
      const result = await service.addIngredientToRecipe(request.params.id, request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.delete('/recipes/:id/ingredients/:detailId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'detailId'],
        properties: { id: { type: 'string', format: 'uuid' }, detailId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageRecipe'])],
    handler: async (request, reply) => {
      await service.removeIngredientFromRecipe(request.params.id, request.params.detailId);
      return { message: 'Ingredient removed' };
    },
  });
}

module.exports = inventoryRoutes;
