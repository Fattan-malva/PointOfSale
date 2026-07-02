exports.up = function(knex) {
  return knex.schema
    .createTable('AuditLog', (table) => {
      table.string('AuditID', 36).primary();
      table.string('UserID', 36).nullable();
      table.string('Module', 50).notNullable();
      table.string('Action', 50).notNullable();
      table.string('TableName', 50).notNullable();
      table.string('RecordID', 36).notNullable();
      table.text('OldValue').nullable();
      table.text('NewValue').nullable();
      table.string('IPAddress', 45).nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    })
    .createTable('UserActivity', (table) => {
      table.string('ActivityID', 36).primary();
      table.string('UserID', 36).notNullable();
      table.string('UserType', 20).notNullable().defaultTo('Employee');
      table.string('Action', 20).notNullable();
      table.string('Device', 100).nullable();
      table.string('IPAddress', 45).nullable();
      table.text('UserAgent').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    });
};

exports.down = function(knex) {
  return knex.schema
    .dropTableIfExists('UserActivity')
    .dropTableIfExists('AuditLog');
};
