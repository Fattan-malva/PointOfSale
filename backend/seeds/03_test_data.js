const crypto = require('crypto');

function uuidv7() {
  const ts = Date.now().toString(16).padStart(12, '0');
  const rand = crypto.randomBytes(9).toString('hex');
  const variant = (8 + Math.floor(Math.random() * 4)).toString(16);
  const hex = ts + '7' + rand.slice(0, 3) + variant + rand.slice(3);
  return `${hex.slice(0,8)}-${hex.slice(8,12)}-${hex.slice(12,16)}-${hex.slice(16,20)}-${hex.slice(20)}`;
}

exports.seed = async (knex) => {
  await knex.transaction(async (trx) => {
    // Skip if items already exist
    const existing = await trx('Item').first();
    if (existing) return;

    // Fetch categories (must exist from earlier seed)
    const categories = await trx('Category').select('*');
    const catMap = {};
    for (const c of categories) {
      catMap[c.CategoryName] = c.CategoryID;
    }

    // ==================== ITEMS ====================
    const items = [
      // Makanan
      {
        ItemID: uuidv7(),
        CategoryID: catMap['Makanan'],
        ItemCode: 'MKN-001',
        ItemName: 'Nasi Goreng Spesial',
        Description: 'Nasi goreng dengan telur, ayam, dan sayuran',
        Price: 25000,
        CostPrice: 12000,
        IsActive: true,
      },
      {
        ItemID: uuidv7(),
        CategoryID: catMap['Makanan'],
        ItemCode: 'MKN-002',
        ItemName: 'Mie Goreng',
        Description: 'Mie goreng dengan sayuran dan telur',
        Price: 22000,
        CostPrice: 10000,
        IsActive: true,
      },
      {
        ItemID: uuidv7(),
        CategoryID: catMap['Makanan'],
        ItemCode: 'MKN-003',
        ItemName: 'Ayam Goreng Crispy',
        Description: 'Ayam goreng crispy dengan nasi dan sambal',
        Price: 30000,
        CostPrice: 15000,
        IsActive: true,
      },
      // Minuman
      {
        ItemID: uuidv7(),
        CategoryID: catMap['Minuman'],
        ItemCode: 'MIN-001',
        ItemName: 'Es Teh Manis',
        Description: 'Es teh manis segar',
        Price: 5000,
        CostPrice: 2000,
        IsActive: true,
      },
      {
        ItemID: uuidv7(),
        CategoryID: catMap['Minuman'],
        ItemCode: 'MIN-002',
        ItemName: 'Es Jeruk',
        Description: 'Es jeruk peras segar',
        Price: 8000,
        CostPrice: 3000,
        IsActive: true,
      },
      // Snack
      {
        ItemID: uuidv7(),
        CategoryID: catMap['Snack'],
        ItemCode: 'SNK-001',
        ItemName: 'Pisang Goreng',
        Description: 'Pisang goreng crispy',
        Price: 10000,
        CostPrice: 4000,
        IsActive: true,
      },
      // Dessert
      {
        ItemID: uuidv7(),
        CategoryID: catMap['Dessert'],
        ItemCode: 'DST-001',
        ItemName: 'Es Krim Vanilla',
        Description: 'Es krim vanilla premium',
        Price: 12000,
        CostPrice: 5000,
        IsActive: true,
      },
    ];

    await trx('Item').insert(items);

    // ==================== MODIFIERS ====================
    // Modifier table represents a group; we will use MaxSelect to indicate single/multiple selection
    const modifiers = [];
    const modifierOptions = [];

    // Level Pedas (single selection)
    const levelPedasId = uuidv7();
    modifiers.push({
      ModifierID: levelPedasId,
      ModifierName: 'Level Pedas',
      IsRequired: false,
      MaxSelect: 1,
      IsActive: true,
    });
    const levelOptions = ['Tidak Pedas', 'Pedas Sedang', 'Pedas Banget'];
    levelOptions.forEach((name, idx) => {
      modifierOptions.push({
        ModifierOptionID: uuidv7(),
        ModifierID: levelPedasId,
        OptionName: name,
        AdditionalPrice: 0,
        SortOrder: idx + 1,
        IsActive: true,
      });
    });

    // Tambahan (multiple selection, allow up to 3)
    const tambahanId = uuidv7();
    modifiers.push({
      ModifierID: tambahanId,
      ModifierName: 'Tambahan',
      IsRequired: false,
      MaxSelect: 3,
      IsActive: true,
    });
    const tambahanOpts = [
      { name: 'Tambah Telur', price: 5000 },
      { name: 'Tambah Ayam', price: 10000 },
      { name: 'Tambah Keju', price: 7000 },
    ];
    tambahanOpts.forEach((opt, idx) => {
      modifierOptions.push({
        ModifierOptionID: uuidv7(),
        ModifierID: tambahanId,
        OptionName: opt.name,
        AdditionalPrice: opt.price,
        SortOrder: idx + 1,
        IsActive: true,
      });
    });

    // Ukuran (single, required)
    const ukuranId = uuidv7();
    modifiers.push({
      ModifierID: ukuranId,
      ModifierName: 'Ukuran',
      IsRequired: true,
      MaxSelect: 1,
      IsActive: true,
    });
    const ukuranOpts = [
      { name: 'Regular', price: 0 },
      { name: 'Large', price: 5000 },
    ];
    ukuranOpts.forEach((opt, idx) => {
      modifierOptions.push({
        ModifierOptionID: uuidv7(),
        ModifierID: ukuranId,
        OptionName: opt.name,
        AdditionalPrice: opt.price,
        SortOrder: idx + 1,
        IsActive: true,
      });
    });

    await trx('Modifier').insert(modifiers);
    await trx('ModifierOption').insert(modifierOptions);

    console.log('✓ Test data seeded successfully');
    console.log(`✓ ${items.length} items inserted`);
    console.log(`✓ ${modifiers.length} modifiers inserted`);
    console.log(`✓ ${modifierOptions.length} modifier options inserted`);
  });
};
