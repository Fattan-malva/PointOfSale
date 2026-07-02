exports.up = function(knex) {
  return knex.schema
    .createTable('Category', (table) => {
      table.string('CategoryID', 36).primary();
      table.string('CategoryName', 100).notNullable();
      table.text('Description').nullable();
      table.integer('SortOrder').notNullable().defaultTo(0);
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Item', (table) => {
      table.string('ItemID', 36).primary();
      table.string('CategoryID', 36).nullable().references('CategoryID').inTable('Category').onDelete('SET NULL');
      table.string('ItemCode', 20).notNullable().unique();
      table.string('ItemName', 100).notNullable();
      table.text('Description').nullable();
      table.decimal('Price', 18, 2).notNullable();
      table.decimal('CostPrice', 18, 2).nullable();
      table.string('ItemType', 20).notNullable().defaultTo('Product');
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Modifier', (table) => {
      table.string('ModifierID', 36).primary();
      table.string('ModifierName', 100).notNullable();
      table.boolean('IsRequired').notNullable().defaultTo(false);
      table.integer('MaxSelect').notNullable().defaultTo(1);
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('ModifierOption', (table) => {
      table.string('ModifierOptionID', 36).primary();
      table.string('ModifierID', 36).notNullable().references('ModifierID').inTable('Modifier').onDelete('CASCADE');
      table.string('OptionName', 100).notNullable();
      table.decimal('AdditionalPrice', 18, 2).notNullable().defaultTo(0);
      table.integer('SortOrder').notNullable().defaultTo(0);
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('ItemModifier', (table) => {
      table.string('ItemModifierID', 36).primary();
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('CASCADE');
      table.string('ModifierID', 36).notNullable().references('ModifierID').inTable('Modifier').onDelete('CASCADE');
      table.integer('SortOrder').notNullable().defaultTo(0);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.unique(['ItemID', 'ModifierID']);
    })
    .createTable('PackageDetail', (table) => {
      table.string('PackageDetailID', 36).primary();
      table.string('PackageItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('CASCADE');
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('NO ACTION');
      table.integer('Qty').notNullable().defaultTo(1);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Table', (table) => {
      table.string('TableID', 36).primary();
      table.string('BranchID', 36).notNullable().references('BranchID').inTable('Branch').onDelete('NO ACTION');
      table.string('TableCode', 20).notNullable();
      table.string('TableName', 100).nullable();
      table.integer('Capacity').notNullable().defaultTo(1);
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
      table.unique(['BranchID', 'TableCode']);
    })
    .createTable('Tax', (table) => {
      table.string('TaxID', 36).primary();
      table.string('TaxName', 100).notNullable();
      table.decimal('TaxRate', 5, 2).notNullable();
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Discount', (table) => {
      table.string('DiscountID', 36).primary();
      table.string('DiscountName', 100).notNullable();
      table.string('DiscountType', 20).notNullable();
      table.decimal('DiscountValue', 18, 2).notNullable();
      table.decimal('MinPurchase', 18, 2).nullable();
      table.decimal('MaxDiscount', 18, 2).nullable();
      table.timestamp('StartDate').nullable();
      table.timestamp('EndDate').nullable();
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Voucher', (table) => {
      table.string('VoucherID', 36).primary();
      table.string('VoucherCode', 50).notNullable().unique();
      table.string('VoucherName', 100).notNullable();
      table.string('DiscountType', 20).notNullable();
      table.decimal('DiscountValue', 18, 2).notNullable();
      table.decimal('MinPurchase', 18, 2).nullable();
      table.integer('MaxUses').nullable();
      table.integer('CurrentUses').notNullable().defaultTo(0);
      table.timestamp('StartDate').nullable();
      table.timestamp('EndDate').nullable();
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('PaymentMethod', (table) => {
      table.string('PaymentMethodID', 36).primary();
      table.string('MethodCode', 20).notNullable().unique();
      table.string('MethodName', 100).notNullable();
      table.string('MethodType', 20).notNullable();
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Shift', (table) => {
      table.string('ShiftID', 36).primary();
      table.string('ShiftCode', 20).notNullable().unique();
      table.string('ShiftName', 100).notNullable();
      table.time('StartTime').notNullable();
      table.time('EndTime').notNullable();
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('MstCustomer', (table) => {
      table.string('CustomerID', 36).primary();
      table.string('CustomerCode', 20).nullable().unique();
      table.string('FullName', 100).notNullable();
      table.string('Phone', 20).nullable();
      table.string('Email', 100).nullable();
      table.string('PasswordHash', 255).nullable();
      table.integer('Point').notNullable().defaultTo(0);
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Media', (table) => {
      table.string('MediaID', 36).primary();
      table.string('FileName', 255).notNullable();
      table.string('FilePath', 500).notNullable();
      table.string('MimeType', 100).nullable();
      table.integer('FileSize').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('ItemMedia', (table) => {
      table.string('ItemMediaID', 36).primary();
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('CASCADE');
      table.string('MediaID', 36).notNullable().references('MediaID').inTable('Media').onDelete('CASCADE');
      table.integer('SortOrder').notNullable().defaultTo(0);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.unique(['ItemID', 'MediaID']);
    });
};

exports.down = function(knex) {
  return knex.schema
    .dropTableIfExists('ItemMedia')
    .dropTableIfExists('Media')
    .dropTableIfExists('MstCustomer')
    .dropTableIfExists('Shift')
    .dropTableIfExists('PaymentMethod')
    .dropTableIfExists('Voucher')
    .dropTableIfExists('Discount')
    .dropTableIfExists('Tax')
    .dropTableIfExists('Table')
    .dropTableIfExists('PackageDetail')
    .dropTableIfExists('ItemModifier')
    .dropTableIfExists('ModifierOption')
    .dropTableIfExists('Modifier')
    .dropTableIfExists('Item')
    .dropTableIfExists('Category');
};
