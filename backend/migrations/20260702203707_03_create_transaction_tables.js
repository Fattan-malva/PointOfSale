exports.up = function(knex) {
  return knex.schema
    .createTable('Order', (table) => {
      table.string('OrderID', 36).primary();
      table.string('BranchID', 36).notNullable().references('BranchID').inTable('Branch').onDelete('NO ACTION');
      table.string('CustomerID', 36).nullable().references('CustomerID').inTable('MstCustomer').onDelete('NO ACTION');
      table.string('TableID', 36).nullable().references('TableID').inTable('Table').onDelete('NO ACTION');
      table.string('UserID', 36).notNullable().references('UserID').inTable('MstUser').onDelete('NO ACTION');
      table.string('OrderNumber', 30).notNullable().unique();
      table.string('OrderType', 20).notNullable().defaultTo('DineIn');
      table.string('Status', 20).notNullable().defaultTo('Draft');
      table.decimal('SubTotal', 18, 2).notNullable().defaultTo(0);
      table.decimal('DiscountTotal', 18, 2).notNullable().defaultTo(0);
      table.decimal('TaxTotal', 18, 2).notNullable().defaultTo(0);
      table.decimal('ServiceCharge', 18, 2).notNullable().defaultTo(0);
      table.decimal('GrandTotal', 18, 2).notNullable().defaultTo(0);
      table.string('PaymentStatus', 20).notNullable().defaultTo('Unpaid');
      table.text('Note').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('OrderDetail', (table) => {
      table.string('OrderDetailID', 36).primary();
      table.string('OrderID', 36).notNullable().references('OrderID').inTable('Order').onDelete('CASCADE');
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('NO ACTION');
      table.string('ItemName', 100).notNullable();
      table.decimal('Qty', 18, 2).notNullable().defaultTo(1);
      table.decimal('Price', 18, 2).notNullable();
      table.decimal('SubTotal', 18, 2).notNullable().defaultTo(0);
      table.text('Note').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('OrderModifier', (table) => {
      table.string('OrderModifierID', 36).primary();
      table.string('OrderDetailID', 36).notNullable().references('OrderDetailID').inTable('OrderDetail').onDelete('CASCADE');
      table.string('ModifierID', 36).nullable();
      table.string('ModifierOptionID', 36).nullable();
      table.string('OptionName', 100).notNullable();
      table.decimal('AdditionalPrice', 18, 2).notNullable().defaultTo(0);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('OrderDiscount', (table) => {
      table.string('OrderDiscountID', 36).primary();
      table.string('OrderID', 36).notNullable().references('OrderID').inTable('Order').onDelete('CASCADE');
      table.string('DiscountID', 36).nullable();
      table.string('DiscountName', 100).notNullable();
      table.string('DiscountType', 20).notNullable();
      table.decimal('DiscountValue', 18, 2).notNullable();
      table.decimal('DiscountAmount', 18, 2).notNullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Payment', (table) => {
      table.string('PaymentID', 36).primary();
      table.string('OrderID', 36).notNullable().references('OrderID').inTable('Order').onDelete('CASCADE');
      table.string('PaymentMethodID', 36).notNullable().references('PaymentMethodID').inTable('PaymentMethod').onDelete('NO ACTION');
      table.decimal('PaymentAmount', 18, 2).notNullable();
      table.string('ReferenceNumber', 100).nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('Kitchen', (table) => {
      table.string('KitchenID', 36).primary();
      table.string('OrderID', 36).notNullable().references('OrderID').inTable('Order').onDelete('CASCADE');
      table.string('OrderDetailID', 36).nullable();
      table.string('ItemName', 100).notNullable();
      table.decimal('Qty', 18, 2).notNullable().defaultTo(1);
      table.string('Status', 20).notNullable().defaultTo('Pending');
      table.text('Note').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('TableHistory', (table) => {
      table.string('TableHistoryID', 36).primary();
      table.string('TableID', 36).notNullable().references('TableID').inTable('Table').onDelete('NO ACTION');
      table.string('OrderID', 36).notNullable().references('OrderID').inTable('Order').onDelete('CASCADE');
      table.timestamp('StartTime').defaultTo(knex.fn.now());
      table.timestamp('EndTime').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('ShiftClosing', (table) => {
      table.string('ShiftClosingID', 36).primary();
      table.string('BranchID', 36).notNullable().references('BranchID').inTable('Branch').onDelete('NO ACTION');
      table.string('UserID', 36).notNullable().references('UserID').inTable('MstUser').onDelete('NO ACTION');
      table.string('ShiftID', 36).notNullable().references('ShiftID').inTable('Shift').onDelete('NO ACTION');
      table.date('OpenDate').notNullable();
      table.date('CloseDate').nullable();
      table.timestamp('OpenTime').notNullable().defaultTo(knex.fn.now());
      table.timestamp('CloseTime').nullable();
      table.decimal('OpeningBalance', 18, 2).notNullable().defaultTo(0);
      table.decimal('ClosingBalance', 18, 2).nullable();
      table.decimal('TotalCash', 18, 2).nullable();
      table.decimal('TotalCard', 18, 2).nullable();
      table.decimal('TotalEwallet', 18, 2).nullable();
      table.decimal('TotalQR', 18, 2).nullable();
      table.decimal('TotalSales', 18, 2).nullable();
      table.decimal('TotalDiscount', 18, 2).nullable();
      table.decimal('TotalTax', 18, 2).nullable();
      table.text('Note').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('VoucherHistory', (table) => {
      table.string('VoucherHistoryID', 36).primary();
      table.string('VoucherID', 36).notNullable().references('VoucherID').inTable('Voucher').onDelete('NO ACTION');
      table.string('OrderID', 36).notNullable().references('OrderID').inTable('Order').onDelete('CASCADE');
      table.string('CustomerID', 36).nullable().references('CustomerID').inTable('MstCustomer').onDelete('NO ACTION');
      table.string('VoucherCode', 50).notNullable();
      table.decimal('DiscountAmount', 18, 2).notNullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('PointHistory', (table) => {
      table.string('PointHistoryID', 36).primary();
      table.string('CustomerID', 36).notNullable().references('CustomerID').inTable('MstCustomer').onDelete('NO ACTION');
      table.string('OrderID', 36).nullable().references('OrderID').inTable('Order').onDelete('NO ACTION');
      table.integer('Point').notNullable();
      table.string('Type', 20).notNullable();
      table.string('Reference', 255).nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    });
};

exports.down = function(knex) {
  return knex.schema
    .dropTableIfExists('PointHistory')
    .dropTableIfExists('VoucherHistory')
    .dropTableIfExists('ShiftClosing')
    .dropTableIfExists('TableHistory')
    .dropTableIfExists('Kitchen')
    .dropTableIfExists('Payment')
    .dropTableIfExists('OrderDiscount')
    .dropTableIfExists('OrderModifier')
    .dropTableIfExists('OrderDetail')
    .dropTableIfExists('Order');
};
