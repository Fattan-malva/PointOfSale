exports.up = function (knex) {
  return knex.schema.alterTable('Item', (table) => {
    // 1. Subtotal Price - Harga dari semua item sebelum diskon & tax = SUM(Qty x UnitPrice)
    table.decimal('SubtotalPrice', 18, 2).notNullable().defaultTo(0);
    // 2. Discount Amount - Potongan harga
    table.decimal('DiscountAmount', 18, 2).notNullable().defaultTo(0);
    // 3. Tax Amount - Pajak yang berlaku
    table.decimal('TaxAmount', 18, 2).notNullable().defaultTo(0);
    // 4. Final Price - Harga akhir yang dibayar = Subtotal - Discount + Tax
    table.decimal('FinalPrice', 18, 2).notNullable().defaultTo(0);
  });
};

exports.down = function (knex) {
  return knex.schema.alterTable('Item', (table) => {
    table.dropColumn('SubtotalPrice');
    table.dropColumn('DiscountAmount');
    table.dropColumn('TaxAmount');
    table.dropColumn('FinalPrice');
  });
};
