exports.up = function(knex) {
  return knex.schema
    .createTable('Supplier', (table) => {
      table.string('SupplierID', 36).primary();
      table.string('SupplierCode', 20).notNullable().unique();
      table.string('SupplierName', 100).notNullable();
      table.string('ContactPerson', 100).nullable();
      table.string('Phone', 20).nullable();
      table.string('Email', 100).nullable();
      table.text('Address').nullable();
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Purchase', (table) => {
      table.string('PurchaseID', 36).primary();
      table.string('BranchID', 36).notNullable().references('BranchID').inTable('Branch').onDelete('NO ACTION');
      table.string('SupplierID', 36).nullable().references('SupplierID').inTable('Supplier').onDelete('NO ACTION');
      table.string('PurchaseNumber', 30).notNullable().unique();
      table.string('Status', 20).notNullable().defaultTo('Draft');
      table.decimal('TotalAmount', 18, 2).notNullable().defaultTo(0);
      table.text('Note').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('PurchaseDetail', (table) => {
      table.string('PurchaseDetailID', 36).primary();
      table.string('PurchaseID', 36).notNullable().references('PurchaseID').inTable('Purchase').onDelete('CASCADE');
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('NO ACTION');
      table.decimal('Qty', 18, 2).notNullable().defaultTo(1);
      table.decimal('UnitCost', 18, 2).notNullable().defaultTo(0);
      table.decimal('SubTotal', 18, 2).notNullable().defaultTo(0);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Stock', (table) => {
      table.string('StockID', 36).primary();
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('NO ACTION');
      table.string('BranchID', 36).notNullable().references('BranchID').inTable('Branch').onDelete('NO ACTION');
      table.decimal('CurrentStock', 18, 2).notNullable().defaultTo(0);
      table.decimal('MinStock', 18, 2).nullable();
      table.decimal('MaxStock', 18, 2).nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
      table.unique(['ItemID', 'BranchID']);
    })
    .createTable('StockMovement', (table) => {
      table.string('StockMovementID', 36).primary();
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('NO ACTION');
      table.string('BranchID', 36).notNullable().references('BranchID').inTable('Branch').onDelete('NO ACTION');
      table.string('Type', 20).notNullable();
      table.string('ReferenceType', 30).nullable();
      table.string('ReferenceID', 36).nullable();
      table.decimal('Qty', 18, 2).notNullable();
      table.decimal('StockBefore', 18, 2).notNullable();
      table.decimal('StockAfter', 18, 2).notNullable();
      table.text('Note').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Recipe', (table) => {
      table.string('RecipeID', 36).primary();
      table.string('ItemID', 36).notNullable().unique().references('ItemID').inTable('Item').onDelete('CASCADE');
      table.string('RecipeName', 100).notNullable();
      table.decimal('Yield', 18, 2).notNullable().defaultTo(1);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('RecipeDetail', (table) => {
      table.string('RecipeDetailID', 36).primary();
      table.string('RecipeID', 36).notNullable().references('RecipeID').inTable('Recipe').onDelete('CASCADE');
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('NO ACTION');
      table.decimal('Qty', 18, 2).notNullable().defaultTo(1);
      table.string('Unit', 20).nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    });
};

exports.down = function(knex) {
  return knex.schema
    .dropTableIfExists('RecipeDetail')
    .dropTableIfExists('Recipe')
    .dropTableIfExists('StockMovement')
    .dropTableIfExists('Stock')
    .dropTableIfExists('PurchaseDetail')
    .dropTableIfExists('Purchase')
    .dropTableIfExists('Supplier');
};
