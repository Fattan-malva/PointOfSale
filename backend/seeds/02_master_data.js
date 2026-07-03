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
  const existing = await knex('Category').first();
  if (existing) {
    console.log('02_master_data: Master data already exists, skipping');
    return;
  }

  await knex.transaction(async (trx) => {
    const catMkn = uuidv7();
    const catMin = uuidv7();
    const catSnk = uuidv7();
    const catDst = uuidv7();
    const catSides = uuidv7();
    const catCofee = uuidv7();

    await trx('Category').insert([
      { CategoryID: catMkn, CategoryName: 'Makanan', Description: 'Makanan utama', SortOrder: 1, IsActive: true },
      { CategoryID: catMin, CategoryName: 'Minuman', Description: 'Minuman segar', SortOrder: 2, IsActive: true },
      { CategoryID: catSnk, CategoryName: 'Snack', Description: 'Camilan ringan', SortOrder: 3, IsActive: true },
      { CategoryID: catDst, CategoryName: 'Dessert', Description: 'Makanan penutup', SortOrder: 4, IsActive: true },
      { CategoryID: catSides, CategoryName: 'Lauk', Description: 'Lauk pauk', SortOrder: 5, IsActive: true },
      { CategoryID: catCofee, CategoryName: 'Kopi', Description: 'Kopi spesial', SortOrder: 6, IsActive: true },
    ]);

    const items = [
      { ItemID: uuidv7(), CategoryID: catMkn, ItemCode: 'MKN-001', ItemName: 'Nasi Goreng Spesial', Description: 'Nasi goreng dengan telur, ayam, udang, dan sayuran', Price: 25000, CostPrice: 12000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catMkn, ItemCode: 'MKN-002', ItemName: 'Mie Goreng', Description: 'Mie goreng dengan sayuran dan telur', Price: 22000, CostPrice: 10000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catMkn, ItemCode: 'MKN-003', ItemName: 'Ayam Goreng Crispy', Description: 'Ayam goreng crispy dengan nasi dan sambal', Price: 30000, CostPrice: 15000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catMkn, ItemCode: 'MKN-004', ItemName: 'Sate Ayam', Description: 'Sate ayam dengan bumbu kacang (10 tusuk)', Price: 35000, CostPrice: 18000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catMkn, ItemCode: 'MKN-005', ItemName: 'Soto Ayam', Description: 'Soto ayam dengan nasi dan kerupuk', Price: 20000, CostPrice: 9000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catMkn, ItemCode: 'MKN-006', ItemName: 'Gado-Gado', Description: 'Gado-gado dengan lontong dan bumbu kacang', Price: 18000, CostPrice: 8000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catMin, ItemCode: 'MIN-001', ItemName: 'Es Teh Manis', Description: 'Es teh manis segar', Price: 5000, CostPrice: 2000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catMin, ItemCode: 'MIN-002', ItemName: 'Es Jeruk', Description: 'Es jeruk peras segar', Price: 8000, CostPrice: 3000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catMin, ItemCode: 'MIN-003', ItemName: 'Jus Alpukat', Description: 'Jus alpukat dengan susu coklat', Price: 15000, CostPrice: 7000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catMin, ItemCode: 'MIN-004', ItemName: 'Jus Mangga', Description: 'Jus mangga segar', Price: 12000, CostPrice: 6000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catMin, ItemCode: 'MIN-005', ItemName: 'Lemon Tea', Description: 'Teh lemon segar', Price: 7000, CostPrice: 3000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catSnk, ItemCode: 'SNK-001', ItemName: 'Pisang Goreng', Description: 'Pisang goreng crispy toping keju dan coklat', Price: 10000, CostPrice: 4000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catSnk, ItemCode: 'SNK-002', ItemName: 'Tahu Isi', Description: 'Tahu isi sayuran (6 pcs)', Price: 8000, CostPrice: 3000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catSnk, ItemCode: 'SNK-003', ItemName: 'Kentang Goreng', Description: 'Kentang goreng crispy dengan saus sambal', Price: 15000, CostPrice: 7000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catSnk, ItemCode: 'SNK-004', ItemName: 'Cireng', Description: 'Cireng isi ayam suwir pedas (5 pcs)', Price: 12000, CostPrice: 5000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catDst, ItemCode: 'DST-001', ItemName: 'Es Krim Vanilla', Description: 'Es krim vanilla premium 2 scoop', Price: 12000, CostPrice: 5000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catDst, ItemCode: 'DST-002', ItemName: 'Puding Coklat', Description: 'Puding coklat dengan vla vanilla', Price: 10000, CostPrice: 4000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catDst, ItemCode: 'DST-003', ItemName: 'Fruit Salad', Description: 'Salad buah segar dengan yogurt', Price: 15000, CostPrice: 7000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catCofee, ItemCode: 'KOP-001', ItemName: 'Kopi Hitam', Description: 'Kopi hitam robusta', Price: 8000, CostPrice: 3000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catCofee, ItemCode: 'KOP-002', ItemName: 'Cappuccino', Description: 'Cappuccino dengan busa susu', Price: 18000, CostPrice: 8000, ItemType: 'Product', IsActive: true },
      { ItemID: uuidv7(), CategoryID: catCofee, ItemCode: 'KOP-003', ItemName: 'Caramel Macchiato', Description: 'Caramel macchiato with espresso', Price: 22000, CostPrice: 10000, ItemType: 'Product', IsActive: true },
    ];

    await trx('Item').insert(items);

    const itemMap = {};
    for (const it of items) {
      itemMap[it.ItemCode] = it.ItemID;
    }

    await trx('Tax').insert({
      TaxID: uuidv7(), TaxName: 'PPN 11%', TaxRate: 11.00, IsActive: true,
    });

    await trx('Discount').insert([
      { DiscountID: uuidv7(), DiscountName: 'Diskon Member 10%', DiscountType: 'Percentage', DiscountValue: 10.00, MinPurchase: 50000, IsActive: true },
      { DiscountID: uuidv7(), DiscountName: 'Diskon Hari Raya 15%', DiscountType: 'Percentage', DiscountValue: 15.00, MinPurchase: 100000, MaxDiscount: 50000, IsActive: true },
      { DiscountID: uuidv7(), DiscountName: 'Voucher Belanja 20rb', DiscountType: 'Nominal', DiscountValue: 20000, MinPurchase: 100000, IsActive: true },
    ]);

    await trx('Voucher').insert([
      { VoucherID: uuidv7(), VoucherCode: 'NEWYEAR2025', VoucherName: 'Tahun Baru 2025', DiscountType: 'Percentage', DiscountValue: 20.00, MinPurchase: 50000, MaxUses: 100, CurrentUses: 0, StartDate: '2025-01-01', EndDate: '2025-12-31', IsActive: true },
      { VoucherID: uuidv7(), VoucherCode: 'WELCOME10', VoucherName: 'Welcome 10%', DiscountType: 'Percentage', DiscountValue: 10.00, MinPurchase: 0, MaxUses: 1000, CurrentUses: 0, StartDate: '2025-01-01', EndDate: '2025-12-31', IsActive: true },
    ]);

    await trx('PaymentMethod').insert([
      { PaymentMethodID: uuidv7(), MethodCode: 'CASH', MethodName: 'Tunai', MethodType: 'Cash', IsActive: true },
      { PaymentMethodID: uuidv7(), MethodCode: 'DEBIT', MethodName: 'Kartu Debit', MethodType: 'Card', IsActive: true },
      { PaymentMethodID: uuidv7(), MethodCode: 'KREDIT', MethodName: 'Kartu Kredit', MethodType: 'Card', IsActive: true },
      { PaymentMethodID: uuidv7(), MethodCode: 'QRIS', MethodName: 'QRIS', MethodType: 'QR', IsActive: true },
      { PaymentMethodID: uuidv7(), MethodCode: 'GOPAY', MethodName: 'GoPay', MethodType: 'E-Wallet', IsActive: true },
    ]);

    await trx('Shift').insert([
      { ShiftID: uuidv7(), ShiftCode: 'PAGI', ShiftName: 'Pagi', StartTime: '07:00', EndTime: '15:00', IsActive: true },
      { ShiftID: uuidv7(), ShiftCode: 'SIANG', ShiftName: 'Siang', StartTime: '15:00', EndTime: '23:00', IsActive: true },
    ]);

    const tables = [];
    for (let i = 1; i <= 10; i++) {
      const code = `M${String(i).padStart(2, '0')}`;
      tables.push({ TableID: uuidv7(), BranchID: BRANCH_ID, TableCode: code, TableName: `Meja ${i}`, Capacity: i <= 3 ? 2 : i <= 7 ? 4 : 6, IsActive: true });
    }
    await trx('Table').insert(tables);

    const modPedas = uuidv7();
    const modTambahan = uuidv7();
    const modUkuran = uuidv7();
    const modTopping = uuidv7();

    await trx('Modifier').insert([
      { ModifierID: modPedas, ModifierName: 'Level Pedas', IsRequired: false, MaxSelect: 1, IsActive: true },
      { ModifierID: modTambahan, ModifierName: 'Tambahan', IsRequired: false, MaxSelect: 3, IsActive: true },
      { ModifierID: modUkuran, ModifierName: 'Ukuran', IsRequired: true, MaxSelect: 1, IsActive: true },
      { ModifierID: modTopping, ModifierName: 'Topping', IsRequired: false, MaxSelect: 3, IsActive: true },
    ]);

    await trx('ModifierOption').insert([
      { ModifierOptionID: uuidv7(), ModifierID: modPedas, OptionName: 'Tidak Pedas', AdditionalPrice: 0, SortOrder: 1, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modPedas, OptionName: 'Pedas Sedang', AdditionalPrice: 0, SortOrder: 2, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modPedas, OptionName: 'Pedas Banget', AdditionalPrice: 0, SortOrder: 3, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modTambahan, OptionName: 'Tambah Telur', AdditionalPrice: 5000, SortOrder: 1, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modTambahan, OptionName: 'Tambah Ayam', AdditionalPrice: 10000, SortOrder: 2, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modTambahan, OptionName: 'Tambah Keju', AdditionalPrice: 7000, SortOrder: 3, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modTambahan, OptionName: 'Tambah Udang', AdditionalPrice: 12000, SortOrder: 4, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modUkuran, OptionName: 'Regular', AdditionalPrice: 0, SortOrder: 1, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modUkuran, OptionName: 'Large', AdditionalPrice: 5000, SortOrder: 2, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modTopping, OptionName: 'Keju Parut', AdditionalPrice: 3000, SortOrder: 1, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modTopping, OptionName: 'Choco Chip', AdditionalPrice: 5000, SortOrder: 2, IsActive: true },
      { ModifierOptionID: uuidv7(), ModifierID: modTopping, OptionName: 'Sprinkle', AdditionalPrice: 2000, SortOrder: 3, IsActive: true },
    ]);

    await trx('ItemModifier').insert([
      { ItemModifierID: uuidv7(), ItemID: itemMap['MKN-001'], ModifierID: modPedas, SortOrder: 1 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['MKN-001'], ModifierID: modTambahan, SortOrder: 2 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['MKN-001'], ModifierID: modUkuran, SortOrder: 3 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['MKN-002'], ModifierID: modPedas, SortOrder: 1 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['MKN-002'], ModifierID: modTambahan, SortOrder: 2 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['MKN-002'], ModifierID: modUkuran, SortOrder: 3 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['MKN-003'], ModifierID: modUkuran, SortOrder: 1 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['MKN-003'], ModifierID: modTambahan, SortOrder: 2 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['MIN-003'], ModifierID: modUkuran, SortOrder: 1 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['MIN-003'], ModifierID: modTopping, SortOrder: 2 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['DST-001'], ModifierID: modTopping, SortOrder: 1 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['DST-002'], ModifierID: modTopping, SortOrder: 1 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['KOP-002'], ModifierID: modUkuran, SortOrder: 1 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['KOP-003'], ModifierID: modUkuran, SortOrder: 1 },
      { ItemModifierID: uuidv7(), ItemID: itemMap['KOP-003'], ModifierID: modTopping, SortOrder: 2 },
    ]);

    console.log('02_master_data: Master data seeded successfully');
    console.log(`  Categories: 6, Items: ${items.length}, Tax: 1, Discount: 3`);
    console.log(`  Voucher: 2, PaymentMethods: 5, Shifts: 2, Tables: ${tables.length}`);
    console.log('  Modifiers: 4, ModifierOptions: 12, ItemModifiers: 15');
  });
};
