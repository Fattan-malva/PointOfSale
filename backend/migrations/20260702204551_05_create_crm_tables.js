exports.up = function(knex) {
  return knex.schema
    .createTable('CustomerAddress', (table) => {
      table.string('AddressID', 36).primary();
      table.string('CustomerID', 36).notNullable().references('CustomerID').inTable('MstCustomer').onDelete('CASCADE');
      table.string('Label', 50).notNullable().defaultTo('Other');
      table.string('ReceiverName', 100).notNullable();
      table.string('Phone', 20).nullable();
      table.text('Address').notNullable();
      table.decimal('Latitude', 10, 7).nullable();
      table.decimal('Longitude', 10, 7).nullable();
      table.boolean('DefaultAddress').notNullable().defaultTo(false);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('CustomerFavorite', (table) => {
      table.string('FavoriteID', 36).primary();
      table.string('CustomerID', 36).notNullable().references('CustomerID').inTable('MstCustomer').onDelete('CASCADE');
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('CASCADE');
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.unique(['CustomerID', 'ItemID']);
    })
    .createTable('CustomerCart', (table) => {
      table.string('CartID', 36).primary();
      table.string('CustomerID', 36).notNullable().references('CustomerID').inTable('MstCustomer').onDelete('CASCADE');
      table.string('ItemID', 36).notNullable().references('ItemID').inTable('Item').onDelete('CASCADE');
      table.decimal('Qty', 18, 2).notNullable().defaultTo(1);
      table.text('Note').nullable();
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
      table.timestamp('UpdatedAt').defaultTo(knex.fn.now());
    })
    .createTable('CustomerNotification', (table) => {
      table.string('NotificationID', 36).primary();
      table.string('CustomerID', 36).notNullable().references('CustomerID').inTable('MstCustomer').onDelete('CASCADE');
      table.string('Title', 200).notNullable();
      table.text('Message').notNullable();
      table.boolean('IsRead').notNullable().defaultTo(false);
      table.timestamp('CreatedAt').defaultTo(knex.fn.now());
    });
};

exports.down = function(knex) {
  return knex.schema
    .dropTableIfExists('CustomerNotification')
    .dropTableIfExists('CustomerCart')
    .dropTableIfExists('CustomerFavorite')
    .dropTableIfExists('CustomerAddress');
};
