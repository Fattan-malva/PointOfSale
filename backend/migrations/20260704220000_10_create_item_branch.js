exports.up = function (knex) {
  return knex.schema.createTable('ItemBranch', (table) => {
    table.string('ItemBranchID', 36).primary();
    table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('CASCADE');
    table.string('BranchID', 36).notNullable().references('BranchID').inTable('Branch').onDelete('CASCADE');
    table.boolean('IsAvailable').notNullable().defaultTo(true);
    table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    table.unique(['ItemID', 'BranchID']);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('ItemBranch');
};
