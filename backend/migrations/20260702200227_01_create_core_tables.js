exports.up = function(knex) {
  return knex.schema
    .createTable('Branch', (table) => {
      table.string('BranchID', 36).primary();
      table.string('BranchCode', 20).notNullable().unique();
      table.string('BranchName', 100).notNullable();
      table.string('Address', 255).nullable();
      table.string('Phone', 20).nullable();
      table.string('Email', 100).nullable();
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('MstRole', (table) => {
      table.string('RoleID', 36).primary();
      table.string('RoleName', 50).notNullable().unique();
      table.text('Description').nullable();
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('MstPermission', (table) => {
      table.string('PermissionID', 36).primary();
      table.string('PermissionName', 100).notNullable().unique();
      table.text('Description').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('RolePermission', (table) => {
      table.string('RolePermissionID', 36).primary();
      table.string('RoleID', 36).notNullable().references('RoleID').inTable('MstRole').onDelete('CASCADE');
      table.string('PermissionID', 36).notNullable().references('PermissionID').inTable('MstPermission').onDelete('CASCADE');
      table.unique(['RoleID', 'PermissionID']);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('MstUser', (table) => {
      table.string('UserID', 36).primary();
      table.string('BranchID', 36).notNullable().references('BranchID').inTable('Branch').onDelete('NO ACTION');
      table.string('RoleID', 36).notNullable().references('RoleID').inTable('MstRole').onDelete('NO ACTION');
      table.string('Username', 50).notNullable().unique();
      table.string('PasswordHash', 255).notNullable();
      table.string('FullName', 100).notNullable();
      table.string('Phone', 20).nullable();
      table.string('Email', 100).nullable();
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('LastLoginAt').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('AppConfig', (table) => {
      table.string('ConfigID', 36).primary();
      table.boolean('EnableKitchen').notNullable().defaultTo(true);
      table.boolean('EnableInventory').notNullable().defaultTo(true);
      table.boolean('EnableCustomerApp').notNullable().defaultTo(true);
      table.boolean('EnableQROrdering').notNullable().defaultTo(true);
      table.boolean('EnableVoucher').notNullable().defaultTo(true);
      table.boolean('EnableDiscount').notNullable().defaultTo(true);
      table.boolean('EnableTax').notNullable().defaultTo(true);
      table.boolean('EnableServiceCharge').notNullable().defaultTo(false);
      table.boolean('EnableSplitBill').notNullable().defaultTo(false);
      table.boolean('EnableReservation').notNullable().defaultTo(false);
      table.boolean('EnableDelivery').notNullable().defaultTo(false);
      table.boolean('EnableLoyalty').notNullable().defaultTo(true);
      table.boolean('EnableMembership').notNullable().defaultTo(true);
      table.boolean('EnableMultiBranch').notNullable().defaultTo(true);
      table.boolean('EnablePrinterBluetooth').notNullable().defaultTo(true);
      table.boolean('EnableKitchenPrinter').notNullable().defaultTo(true);
      table.boolean('EnableCashDrawer').notNullable().defaultTo(true);
      table.string('Currency', 10).notNullable().defaultTo('IDR');
      table.integer('DecimalDigit').notNullable().defaultTo(2);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    });
};

exports.down = function(knex) {
  return knex.schema
    .dropTableIfExists('AppConfig')
    .dropTableIfExists('MstUser')
    .dropTableIfExists('RolePermission')
    .dropTableIfExists('MstPermission')
    .dropTableIfExists('MstRole')
    .dropTableIfExists('Branch');
};
