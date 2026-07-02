const crypto = require('crypto');

function uuidv7() {
  const ts = Date.now().toString(16).padStart(12, '0');
  const rand = crypto.randomBytes(9).toString('hex');
  const variant = (8 + Math.floor(Math.random() * 4)).toString(16);
  const hex = ts + '7' + rand.slice(0, 3) + variant + rand.slice(3);
  return hex.slice(0,8) + '-' + hex.slice(8,12) + '-' + hex.slice(12,16) + '-' + hex.slice(16,20) + '-' + hex.slice(20);
}

exports.seed = async (knex) => {
  await knex.transaction(async (trx) => {
    const existing = await trx('Supplier').first();
    if (existing) return;

    await trx('Supplier').insert([
      {
        SupplierID: uuidv7(),
        SupplierCode: 'SUP-001',
        SupplierName: 'PT Sumber Makmur',
        ContactPerson: 'Budi',
        Phone: '021-1111111',
        IsActive: true,
      },
      {
        SupplierID: uuidv7(),
        SupplierCode: 'SUP-002',
        SupplierName: 'CV Bahan Segar',
        ContactPerson: 'Ani',
        Phone: '021-2222222',
        IsActive: true,
      },
    ]);
  });
};
