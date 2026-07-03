const crypto = require('crypto');

function uuidv7() {
  const ts = Date.now().toString(16).padStart(12, '0');
  const rand = crypto.randomBytes(9).toString('hex');
  const variant = (8 + Math.floor(Math.random() * 4)).toString(16);
  const hex = ts + '7' + rand.slice(0, 3) + variant + rand.slice(3);
  return hex.slice(0, 8) + '-' + hex.slice(8, 12) + '-' + hex.slice(12, 16) + '-' + hex.slice(16, 20) + '-' + hex.slice(20);
}

const BRANCH_ID = '00000000-0000-0000-0000-000000000001';

exports.seed = async (knex) => {
  const existing = await knex('Supplier').first();
  if (existing) {
    console.log('03_inventory: Inventory data already exists, skipping');
    return;
  }

  const items = await knex('Item').select('ItemID', 'ItemCode', 'ItemName');
  const itemMap = {};
  for (const it of items) {
    itemMap[it.ItemCode] = it;
  }

  await knex.transaction(async (trx) => {
    const sup1 = uuidv7();
    const sup2 = uuidv7();

    await trx('Supplier').insert([
      { SupplierID: sup1, SupplierCode: 'SUP-001', SupplierName: 'PT Sumber Makmur', ContactPerson: 'Budi', Phone: '021-1111111', Email: 'budi@sumbermakmur.com', Address: 'Jl. Industri Raya No. 10', IsActive: true },
      { SupplierID: sup2, SupplierCode: 'SUP-002', SupplierName: 'CV Bahan Segar', ContactPerson: 'Ani', Phone: '021-2222222', Email: 'ani@bahansegar.com', Address: 'Jl. Pasar Baru No. 5', IsActive: true },
      { SupplierID: uuidv7(), SupplierCode: 'SUP-003', SupplierName: 'UD Berkah Abadi', ContactPerson: 'Rudi', Phone: '021-3333333', Email: 'rudi@berkahabadi.com', Address: 'Jl. Merpati No. 22', IsActive: true },
    ]);

    const stocks = [
      { ItemCode: 'MKN-001', Qty: 50 }, { ItemCode: 'MKN-002', Qty: 40 },
      { ItemCode: 'MKN-003', Qty: 30 }, { ItemCode: 'MKN-004', Qty: 25 },
      { ItemCode: 'MKN-005', Qty: 35 }, { ItemCode: 'MKN-006', Qty: 20 },
      { ItemCode: 'MIN-001', Qty: 100 }, { ItemCode: 'MIN-002', Qty: 80 },
      { ItemCode: 'MIN-003', Qty: 60 }, { ItemCode: 'MIN-004', Qty: 50 },
      { ItemCode: 'MIN-005', Qty: 70 }, { ItemCode: 'SNK-001', Qty: 45 },
      { ItemCode: 'SNK-002', Qty: 40 }, { ItemCode: 'SNK-003', Qty: 55 },
      { ItemCode: 'SNK-004', Qty: 35 }, { ItemCode: 'DST-001', Qty: 30 },
      { ItemCode: 'DST-002', Qty: 25 }, { ItemCode: 'DST-003', Qty: 20 },
      { ItemCode: 'KOP-001', Qty: 90 }, { ItemCode: 'KOP-002', Qty: 60 },
      { ItemCode: 'KOP-003', Qty: 40 },
    ];

    const stockInserts = [];
    for (const s of stocks) {
      if (itemMap[s.ItemCode]) {
        stockInserts.push({
          StockID: uuidv7(),
          ItemID: itemMap[s.ItemCode].ItemID,
          BranchID: BRANCH_ID,
          CurrentStock: s.Qty,
          MinStock: Math.round(s.Qty * 0.2),
          MaxStock: Math.round(s.Qty * 2),
        });
      }
    }
    await trx('Stock').insert(stockInserts);

    for (const s of stocks) {
      if (itemMap[s.ItemCode]) {
        await trx('StockMovement').insert({
          StockMovementID: uuidv7(),
          ItemID: itemMap[s.ItemCode].ItemID,
          BranchID: BRANCH_ID,
          Type: 'In',
          ReferenceType: 'Initial',
          Qty: s.Qty,
          StockBefore: 0,
          StockAfter: s.Qty,
          Note: 'Stock awal dari seed',
        });
      }
    }

    const recipeData = [
      { code: 'MKN-001', name: 'Resep Nasi Goreng Spesial', yield: 1, details: [{ code: 'MKN-003', qty: 0.2 }, { code: 'MIN-001', qty: 1 }] },
      { code: 'MKN-002', name: 'Resep Mie Goreng', yield: 1, details: [] },
      { code: 'MIN-001', name: 'Resep Es Teh Manis', yield: 1, details: [] },
    ];

    for (const r of recipeData) {
      if (itemMap[r.code]) {
        const recipeId = uuidv7();
        await trx('Recipe').insert({
          RecipeID: recipeId,
          ItemID: itemMap[r.code].ItemID,
          RecipeName: r.name,
          Yield: r.yield,
        });

        for (const d of r.details) {
          if (itemMap[d.code]) {
            await trx('RecipeDetail').insert({
              RecipeDetailID: uuidv7(),
              RecipeID: recipeId,
              ItemID: itemMap[d.code].ItemID,
              Qty: d.qty,
            });
          }
        }
      }
    }

    console.log('03_inventory: Inventory data seeded successfully');
    console.log(`  Suppliers: 3, Stock: ${stockInserts.length} items, Recipes: ${recipeData.length}`);
  });
};
