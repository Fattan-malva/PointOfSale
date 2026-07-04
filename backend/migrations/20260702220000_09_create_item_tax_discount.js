exports.up = function (knex) {
  return knex.schema
    .createTable('ItemTax', (table) => {
      table.string('ItemTaxID', 36).primary();
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('CASCADE');
      table.string('TaxID', 36).notNullable().references('TaxID').inTable('Tax').onDelete('CASCADE');
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.unique(['ItemID', 'TaxID']);
    })
    .createTable('ItemDiscount', (table) => {
      table.string('ItemDiscountID', 36).primary();
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('CASCADE');
      table.string('DiscountID', 36).notNullable().references('DiscountID').inTable('Discount').onDelete('CASCADE');
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.unique(['ItemID', 'DiscountID']);
    });
};

exports.down = function (knex) {
  return knex.schema
    .dropTableIfExists('ItemDiscount')
    .dropTableIfExists('ItemTax');
};
