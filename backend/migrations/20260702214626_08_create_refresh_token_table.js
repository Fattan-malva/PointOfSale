exports.up = function(knex) {
  return knex.schema.createTable('RefreshToken', (table) => {
    table.string('RefreshTokenID', 36).primary();
    table.string('UserID', 36).notNullable();
    table.string('UserType', 20).notNullable().defaultTo('Employee');
    table.string('Token', 255).notNullable().unique();
    table.timestamp('ExpiresAt').notNullable();
    table.boolean('IsRevoked').notNullable().defaultTo(false);
    table.timestamp('CreatedAt').defaultTo(knex.fn.now());
  });
};

exports.down = function(knex) {
  return knex.schema.dropTableIfExists('RefreshToken');
};
