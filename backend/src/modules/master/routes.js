const MasterService = require('./service');

async function masterRoutes(fastify, opts) {
  const service = new MasterService();

  const idParam = {
    type: 'object',
    required: ['id'],
    properties: { id: { type: 'string', format: 'uuid' } },
  };

  fastify.get('/categories', {
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      const { limit, offset, search } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllCategory({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined, search }),
        service.countAllCategory({ search }),
      ]);
      return { data, total };
    },
  });

  fastify.get('/categories/:id', {
    schema: { params: idParam },
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      return { data: await service.getCategoryById(request.params.id) };
    },
  });

  fastify.post('/categories', {
    schema: {
      body: {
        type: 'object',
        required: ['CategoryName'],
        properties: {
          CategoryName: { type: 'string', minLength: 2, maxLength: 100 },
          Description: { type: 'string' },
          SortOrder: { type: 'integer' },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageCategory'])],
    handler: async (request, reply) => {
      const result = await service.createCategory(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/categories/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageCategory'])],
    handler: async (request, reply) => {
      return { data: await service.updateCategory(request.params.id, request.body) };
    },
  });

  fastify.delete('/categories/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageCategory'])],
    handler: async (request, reply) => {
      await service.deleteCategory(request.params.id);
      return { message: 'Category deleted' };
    },
  });

  fastify.get('/items', {
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      const { limit, offset, search, CategoryID, ItemType, branchId } = request.query;
      const params = {
        limit: limit ? parseInt(limit) : undefined,
        offset: offset ? parseInt(offset) : undefined,
        search,
        categoryId: CategoryID,
        itemType: ItemType,
        branchId,
      };
      const countParams = { search, categoryId: CategoryID, itemType: ItemType, branchId };
      const [data, { total }] = await Promise.all([
        service.getAllItem(params),
        service.countAllItem(countParams),
      ]);
      return { data, total };
    },
  });

  fastify.get('/items/:id', {
    schema: { params: idParam },
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      return { data: await service.getItemById(request.params.id) };
    },
  });

  fastify.post('/items', {
    schema: {
      body: {
        type: 'object',
        required: ['ItemCode', 'ItemName', 'Price'],
        properties: {
          CategoryID: { type: 'string', format: 'uuid' },
          ItemCode: { type: 'string', minLength: 1, maxLength: 20 },
          ItemName: { type: 'string', minLength: 2, maxLength: 100 },
          Description: { type: 'string' },
          Price: { type: 'number', minimum: 0 },
          CostPrice: { type: 'number', minimum: 0 },
          SubtotalPrice: { type: 'number', minimum: 0 },
          DiscountAmount: { type: 'number', minimum: 0 },
          TaxAmount: { type: 'number', minimum: 0 },
          FinalPrice: { type: 'number', minimum: 0 },
          ItemType: { type: 'string', enum: ['Product', 'Package', 'Modifier'] },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageItem'])],
    handler: async (request, reply) => {
      const result = await service.createItem(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/items/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageItem'])],
    handler: async (request, reply) => {
      return { data: await service.updateItem(request.params.id, request.body) };
    },
  });

  fastify.delete('/items/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageItem'])],
    handler: async (request, reply) => {
      await service.deleteItem(request.params.id);
      return { message: 'Item deleted' };
    },
  });

  fastify.get('/items/:id/modifiers', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      return { data: await service.getModifiersByItemId(request.params.id) };
    },
  });

  fastify.post('/items/:id/modifiers/:modifierId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'modifierId'],
        properties: { id: { type: 'string', format: 'uuid' }, modifierId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      await service.assignModifierToItem(request.params.id, request.params.modifierId);
      reply.code(201);
      return { message: 'Modifier assigned' };
    },
  });

  fastify.delete('/items/:id/modifiers/:modifierId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'modifierId'],
        properties: { id: { type: 'string', format: 'uuid' }, modifierId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      await service.removeModifierFromItem(request.params.id, request.params.modifierId);
      return { message: 'Modifier removed' };
    },
  });

  fastify.get('/items/:id/packages', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManagePackage'])],
    handler: async (request, reply) => {
      return { data: await service.getPackageDetails(request.params.id) };
    },
  });

  fastify.post('/items/:id/packages', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        required: ['ItemID', 'Qty'],
        properties: {
          ItemID: { type: 'string', format: 'uuid' },
          Qty: { type: 'integer', minimum: 1 },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePackage'])],
    handler: async (request, reply) => {
      const result = await service.createPackageDetail({
        PackageItemID: request.params.id,
        ItemID: request.body.ItemID,
        Qty: request.body.Qty,
      });
      reply.code(201);
      return { data: result };
    },
  });

  fastify.delete('/items/:id/packages/:detailId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'detailId'],
        properties: { id: { type: 'string', format: 'uuid' }, detailId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePackage'])],
    handler: async (request, reply) => {
      await service.deletePackageDetail(request.params.detailId);
      return { message: 'Package detail deleted' };
    },
  });

  fastify.get('/items/:id/media', {
    schema: { params: idParam },
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      return { data: await service.getMediaByItemId(request.params.id) };
    },
  });

  fastify.post('/items/:id/media/:mediaId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'mediaId'],
        properties: { id: { type: 'string', format: 'uuid' }, mediaId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageMedia'])],
    handler: async (request, reply) => {
      const sortOrder = request.body?.SortOrder || 0;
      await service.assignMediaToItem(request.params.id, request.params.mediaId, sortOrder);
      reply.code(201);
      return { message: 'Media assigned' };
    },
  });

  fastify.delete('/items/:id/media/:mediaId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'mediaId'],
        properties: { id: { type: 'string', format: 'uuid' }, mediaId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageMedia'])],
    handler: async (request, reply) => {
      await service.removeMediaFromItem(request.params.id, request.params.mediaId);
      return { message: 'Media removed' };
    },
  });

  fastify.get('/items/:id/taxes', {
    schema: { params: idParam },
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      return { data: await service.getTaxesByItemId(request.params.id) };
    },
  });

  fastify.post('/items/:id/taxes/:taxId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'taxId'],
        properties: { id: { type: 'string', format: 'uuid' }, taxId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageItem'])],
    handler: async (request, reply) => {
      await service.assignTaxToItem(request.params.id, request.params.taxId);
      reply.code(201);
      return { message: 'Tax assigned' };
    },
  });

  fastify.delete('/items/:id/taxes/:taxId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'taxId'],
        properties: { id: { type: 'string', format: 'uuid' }, taxId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageItem'])],
    handler: async (request, reply) => {
      await service.removeTaxFromItem(request.params.id, request.params.taxId);
      return { message: 'Tax removed' };
    },
  });

  fastify.get('/items/:id/discounts', {
    schema: { params: idParam },
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      return { data: await service.getDiscountsByItemId(request.params.id) };
    },
  });

  fastify.post('/items/:id/discounts/:discountId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'discountId'],
        properties: { id: { type: 'string', format: 'uuid' }, discountId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageItem'])],
    handler: async (request, reply) => {
      await service.assignDiscountToItem(request.params.id, request.params.discountId);
      reply.code(201);
      return { message: 'Discount assigned' };
    },
  });

  fastify.delete('/items/:id/discounts/:discountId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'discountId'],
        properties: { id: { type: 'string', format: 'uuid' }, discountId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageItem'])],
    handler: async (request, reply) => {
      await service.removeDiscountFromItem(request.params.id, request.params.discountId);
      return { message: 'Discount removed' };
    },
  });

  fastify.get('/items/:id/branches', {
    schema: { params: idParam },
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      const branches = await service.repo.findBranchesByItemId(request.params.id);
      return { data: branches };
    },
  });

  fastify.post('/items/:id/branches/:branchId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'branchId'],
        properties: { id: { type: 'string', format: 'uuid' }, branchId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageItem'])],
    handler: async (request, reply) => {
      await service.getItemById(request.params.id);
      await service.repo.assignBranchToItem(request.params.id, request.params.branchId);
      reply.code(201);
      return { message: 'Branch assigned' };
    },
  });

  fastify.delete('/items/:id/branches/:branchId', {
    schema: {
      params: {
        type: 'object',
        required: ['id', 'branchId'],
        properties: { id: { type: 'string', format: 'uuid' }, branchId: { type: 'string', format: 'uuid' } },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageItem'])],
    handler: async (request, reply) => {
      await service.getItemById(request.params.id);
      await service.repo.removeBranchFromItem(request.params.id, request.params.branchId);
      return { message: 'Branch removed' };
    },
  });

  fastify.get('/modifiers', {
    preHandler: [fastify.checkPermission(['CanManageItem', 'CanViewMenu'])],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllModifier({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllModifier(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/modifiers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      return { data: await service.getModifierById(request.params.id) };
    },
  });

  fastify.post('/modifiers', {
    schema: {
      body: {
        type: 'object',
        required: ['ModifierName'],
        properties: {
          ModifierName: { type: 'string', minLength: 2, maxLength: 100 },
          IsRequired: { type: 'boolean' },
          MaxSelect: { type: 'integer', minimum: 1 },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      const result = await service.createModifier(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/modifiers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      return { data: await service.updateModifier(request.params.id, request.body) };
    },
  });

  fastify.delete('/modifiers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      await service.deleteModifier(request.params.id);
      return { message: 'Modifier deleted' };
    },
  });

  fastify.get('/modifiers/:id/options', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      return { data: await service.getOptionsByModifierId(request.params.id) };
    },
  });

  fastify.post('/modifiers/:id/options', {
    schema: {
      params: idParam,
      body: {
        type: 'object',
        required: ['OptionName'],
        properties: {
          OptionName: { type: 'string', minLength: 1, maxLength: 100 },
          AdditionalPrice: { type: 'number', minimum: 0 },
          SortOrder: { type: 'integer' },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      const result = await service.createModifierOption({
        ...request.body,
        ModifierID: request.params.id,
      });
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/modifier-options/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      return { data: await service.updateModifierOption(request.params.id, request.body) };
    },
  });

  fastify.delete('/modifier-options/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageModifier'])],
    handler: async (request, reply) => {
      await service.deleteModifierOption(request.params.id);
      return { message: 'Modifier option deleted' };
    },
  });

  fastify.get('/tables', {
    preHandler: [fastify.checkPermission(['CanManageTable', 'CanViewTable'])],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllTable({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllTable(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/tables/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageTable', 'CanViewTable'])],
    handler: async (request, reply) => {
      return { data: await service.getTableById(request.params.id) };
    },
  });

  fastify.post('/tables', {
    schema: {
      body: {
        type: 'object',
        required: ['BranchID', 'TableCode'],
        properties: {
          BranchID: { type: 'string', format: 'uuid' },
          TableCode: { type: 'string', minLength: 1, maxLength: 20 },
          TableName: { type: 'string', maxLength: 100 },
          Capacity: { type: 'integer', minimum: 1 },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageTable'])],
    handler: async (request, reply) => {
      const result = await service.createTable(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/tables/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageTable'])],
    handler: async (request, reply) => {
      return { data: await service.updateTable(request.params.id, request.body) };
    },
  });

  fastify.delete('/tables/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageTable'])],
    handler: async (request, reply) => {
      await service.deleteTable(request.params.id);
      return { message: 'Table deleted' };
    },
  });

  fastify.get('/taxes', {
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllTax({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllTax(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/taxes/:id', {
    schema: { params: idParam },
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      return { data: await service.getTaxById(request.params.id) };
    },
  });

  fastify.post('/taxes', {
    schema: {
      body: {
        type: 'object',
        required: ['TaxName', 'TaxRate'],
        properties: {
          TaxName: { type: 'string', minLength: 2, maxLength: 100 },
          TaxRate: { type: 'number', minimum: 0, maximum: 100 },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageTax'])],
    handler: async (request, reply) => {
      const result = await service.createTax(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/taxes/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageTax'])],
    handler: async (request, reply) => {
      return { data: await service.updateTax(request.params.id, request.body) };
    },
  });

  fastify.delete('/taxes/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageTax'])],
    handler: async (request, reply) => {
      await service.deleteTax(request.params.id);
      return { message: 'Tax deleted' };
    },
  });

  fastify.get('/discounts', {
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllDiscount({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllDiscount(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/discounts/:id', {
    schema: { params: idParam },
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      return { data: await service.getDiscountById(request.params.id) };
    },
  });

  fastify.post('/discounts', {
    schema: {
      body: {
        type: 'object',
        required: ['DiscountName', 'DiscountType', 'DiscountValue'],
        properties: {
          DiscountName: { type: 'string', minLength: 2, maxLength: 100 },
          DiscountType: { type: 'string', enum: ['Percentage', 'Nominal'] },
          DiscountValue: { type: 'number', minimum: 0 },
          MinPurchase: { type: 'number', minimum: 0 },
          MaxDiscount: { type: 'number', minimum: 0 },
          StartDate: { type: 'string', format: 'date-time' },
          EndDate: { type: 'string', format: 'date-time' },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageDiscount'])],
    handler: async (request, reply) => {
      const result = await service.createDiscount(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/discounts/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageDiscount'])],
    handler: async (request, reply) => {
      return { data: await service.updateDiscount(request.params.id, request.body) };
    },
  });

  fastify.delete('/discounts/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageDiscount'])],
    handler: async (request, reply) => {
      await service.deleteDiscount(request.params.id);
      return { message: 'Discount deleted' };
    },
  });

  fastify.get('/vouchers', {
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllVoucher({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllVoucher(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/vouchers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageVoucher'])],
    handler: async (request, reply) => {
      return { data: await service.getVoucherById(request.params.id) };
    },
  });

  fastify.post('/vouchers', {
    schema: {
      body: {
        type: 'object',
        required: ['VoucherCode', 'VoucherName', 'DiscountType', 'DiscountValue'],
        properties: {
          VoucherCode: { type: 'string', minLength: 2, maxLength: 50 },
          VoucherName: { type: 'string', minLength: 2, maxLength: 100 },
          DiscountType: { type: 'string', enum: ['Percentage', 'Nominal'] },
          DiscountValue: { type: 'number', minimum: 0 },
          MinPurchase: { type: 'number', minimum: 0 },
          MaxUses: { type: 'integer', minimum: 1 },
          StartDate: { type: 'string', format: 'date-time' },
          EndDate: { type: 'string', format: 'date-time' },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageVoucher'])],
    handler: async (request, reply) => {
      const result = await service.createVoucher(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/vouchers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageVoucher'])],
    handler: async (request, reply) => {
      return { data: await service.updateVoucher(request.params.id, request.body) };
    },
  });

  fastify.delete('/vouchers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageVoucher'])],
    handler: async (request, reply) => {
      await service.deleteVoucher(request.params.id);
      return { message: 'Voucher deleted' };
    },
  });

  fastify.get('/payment-methods', {
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllPaymentMethod({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllPaymentMethod(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/payment-methods/:id', {
    schema: { params: idParam },
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      return { data: await service.getPaymentMethodById(request.params.id) };
    },
  });

  fastify.post('/payment-methods', {
    schema: {
      body: {
        type: 'object',
        required: ['MethodCode', 'MethodName', 'MethodType'],
        properties: {
          MethodCode: { type: 'string', minLength: 1, maxLength: 20 },
          MethodName: { type: 'string', minLength: 2, maxLength: 100 },
          MethodType: { type: 'string', enum: ['Cash', 'Card', 'QR', 'Transfer', 'E-Wallet'] },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManagePaymentMethod'])],
    handler: async (request, reply) => {
      const result = await service.createPaymentMethod(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/payment-methods/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManagePaymentMethod'])],
    handler: async (request, reply) => {
      return { data: await service.updatePaymentMethod(request.params.id, request.body) };
    },
  });

  fastify.delete('/payment-methods/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManagePaymentMethod'])],
    handler: async (request, reply) => {
      await service.deletePaymentMethod(request.params.id);
      return { message: 'Payment method deleted' };
    },
  });

  fastify.get('/shifts', {
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllShift({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllShift(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/shifts/:id', {
    schema: { params: idParam },
    preHandler: [fastify.authenticate],
    handler: async (request, reply) => {
      return { data: await service.getShiftById(request.params.id) };
    },
  });

  fastify.post('/shifts', {
    schema: {
      body: {
        type: 'object',
        required: ['ShiftCode', 'ShiftName', 'StartTime', 'EndTime'],
        properties: {
          ShiftCode: { type: 'string', minLength: 1, maxLength: 20 },
          ShiftName: { type: 'string', minLength: 2, maxLength: 100 },
          StartTime: { type: 'string' },
          EndTime: { type: 'string' },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageShift'])],
    handler: async (request, reply) => {
      const result = await service.createShift(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/shifts/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageShift'])],
    handler: async (request, reply) => {
      return { data: await service.updateShift(request.params.id, request.body) };
    },
  });

  fastify.delete('/shifts/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageShift'])],
    handler: async (request, reply) => {
      await service.deleteShift(request.params.id);
      return { message: 'Shift deleted' };
    },
  });

  fastify.get('/customers', {
    preHandler: [fastify.checkPermission(['CanViewCustomer'])],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllCustomer({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllCustomer(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/customers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageCustomer'])],
    handler: async (request, reply) => {
      return { data: await service.getCustomerById(request.params.id) };
    },
  });

  fastify.post('/customers', {
    schema: {
      body: {
        type: 'object',
        required: ['FullName'],
        properties: {
          CustomerCode: { type: 'string', maxLength: 20 },
          FullName: { type: 'string', minLength: 2, maxLength: 100 },
          Phone: { type: 'string', maxLength: 20 },
          Email: { type: 'string', maxLength: 100 },
          IsActive: { type: 'boolean' },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageCustomer'])],
    handler: async (request, reply) => {
      const result = await service.createCustomer(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.put('/customers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageCustomer'])],
    handler: async (request, reply) => {
      return { data: await service.updateCustomer(request.params.id, request.body) };
    },
  });

  fastify.delete('/customers/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageCustomer'])],
    handler: async (request, reply) => {
      await service.deleteCustomer(request.params.id);
      return { message: 'Customer deleted' };
    },
  });

  fastify.get('/media', {
    preHandler: [fastify.checkPermission(['CanManageItem'])],
    handler: async (request, reply) => {
      const { limit, offset } = request.query;
      const [data, { total }] = await Promise.all([
        service.getAllMedia({ limit: limit ? parseInt(limit) : undefined, offset: offset ? parseInt(offset) : undefined }),
        service.countAllMedia(),
      ]);
      return { data, total };
    },
  });

  fastify.get('/media/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageMedia'])],
    handler: async (request, reply) => {
      return { data: await service.getMediaById(request.params.id) };
    },
  });

  fastify.post('/media', {
    schema: {
      body: {
        type: 'object',
        required: ['FileName', 'FilePath'],
        properties: {
          FileName: { type: 'string', minLength: 1, maxLength: 255 },
          FilePath: { type: 'string', minLength: 1, maxLength: 500 },
          MimeType: { type: 'string', maxLength: 100 },
          FileSize: { type: 'integer', minimum: 0 },
        },
      },
    },
    preHandler: [fastify.checkPermission(['CanManageMedia'])],
    handler: async (request, reply) => {
      const result = await service.createMedia(request.body);
      reply.code(201);
      return { data: result };
    },
  });

  fastify.delete('/media/:id', {
    schema: { params: idParam },
    preHandler: [fastify.checkPermission(['CanManageMedia'])],
    handler: async (request, reply) => {
      await service.deleteMedia(request.params.id);
      return { message: 'Media deleted' };
    },
  });
}

module.exports = masterRoutes;
