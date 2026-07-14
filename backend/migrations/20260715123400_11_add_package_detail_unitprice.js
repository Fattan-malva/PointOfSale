exports.up = function (knex) {
  return knex.schema.alterTable('PackageDetail', (table) => {
    table.decimal('UnitPrice', 18, 2).notNullable().defaultTo(0);
  });
};

exports.down = function (knex) {
  return knex.schema.alterTable('PackageDetail', (table) => {
    table.dropColumn('UnitPrice');
  });
};