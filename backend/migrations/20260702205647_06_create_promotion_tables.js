exports.up = function(knex) {
  return knex.schema
    .createTable('Promotion', (table) => {
      table.string('PromotionID', 36).primary();
      table.string('PromotionName', 100).notNullable();
      table.text('Description').nullable();
      table.timestamp('StartDate').notNullable();
      table.timestamp('EndDate').nullable();
      table.decimal('MinimumPurchase', 18, 2).nullable();
      table.decimal('MaximumDiscount', 18, 2).nullable();
      table.string('PromotionType', 30).notNullable();
      table.string('DiscountType', 20).nullable();
      table.decimal('DiscountValue', 18, 2).nullable();
      table.integer('BuyQty').nullable();
      table.integer('FreeQty').nullable();
      table.integer('Priority').notNullable().defaultTo(0);
      table.boolean('IsActive').notNullable().defaultTo(true);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('PromotionItem', (table) => {
      table.string('PromotionItemID', 36).primary();
      table.string('PromotionID', 36).notNullable().references('PromotionID').inTable('Promotion').onDelete('CASCADE');
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('CASCADE');
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.unique(['PromotionID', 'ItemID']);
    });
};

exports.down = function(knex) {
  return knex.schema
    .dropTableIfExists('PromotionItem')
    .dropTableIfExists('Promotion');
};
