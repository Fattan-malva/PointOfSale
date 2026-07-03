const crypto = require('crypto');

function uuidv7() {
  const ts = Date.now().toString(16).padStart(12, '0');
  const rand = crypto.randomBytes(9).toString('hex');
  const variant = (8 + Math.floor(Math.random() * 4)).toString(16);
  const hex = ts + '7' + rand.slice(0, 3) + variant + rand.slice(3);
  return hex.slice(0, 8) + '-' + hex.slice(8, 12) + '-' + hex.slice(12, 16) + '-' + hex.slice(16, 20) + '-' + hex.slice(20);
}

exports.seed = async (knex) => {
  const existing = await knex('Promotion').first();
  if (existing) {
    console.log('04_crm_promotion: Data already exists, skipping');
    return;
  }

  const customers = await knex('MstCustomer').select('CustomerID', 'CustomerCode');
  const items = await knex('Item').select('ItemID', 'ItemCode');
  const itemMap = {};
  for (const it of items) {
    itemMap[it.ItemCode] = it.ItemID;
  }

  const custMap = {};
  for (const c of customers) {
    custMap[c.CustomerCode] = c.CustomerID;
  }

  await knex.transaction(async (trx) => {
    if (custMap['CUST-001']) {
      const cid = custMap['CUST-001'];

      await trx('CustomerAddress').insert([
        { AddressID: uuidv7(), CustomerID: cid, Label: 'Rumah', ReceiverName: 'Budi Santoso', Phone: '0813-1111111', Address: 'Jl. Merdeka No. 10, Jakarta', DefaultAddress: true },
        { AddressID: uuidv7(), CustomerID: cid, Label: 'Kantor', ReceiverName: 'Budi Santoso', Phone: '0813-1111111', Address: 'Jl. Sudirman Kav 5, Jakarta', DefaultAddress: false },
      ]);

      if (itemMap['MKN-001']) {
        await trx('CustomerFavorite').insert([
          { FavoriteID: uuidv7(), CustomerID: cid, ItemID: itemMap['MKN-001'] },
          { FavoriteID: uuidv7(), CustomerID: cid, ItemID: itemMap['MIN-001'] },
          { FavoriteID: uuidv7(), CustomerID: cid, ItemID: itemMap['DST-001'] },
        ]);
      }

      if (itemMap['MKN-003']) {
        await trx('CustomerCart').insert([
          { CartID: uuidv7(), CustomerID: cid, ItemID: itemMap['MKN-003'], Qty: 2, Note: 'Sambal pisah' },
          { CartID: uuidv7(), CustomerID: cid, ItemID: itemMap['MIN-003'], Qty: 1, Note: 'Extra susu' },
        ]);
      }

      await trx('CustomerNotification').insert([
        { NotificationID: uuidv7(), CustomerID: cid, Title: 'Selamat Datang', Message: 'Selamat datang di POS App! Nikmati diskon 10% untuk pesanan pertama Anda.', IsRead: false },
        { NotificationID: uuidv7(), CustomerID: cid, Title: 'Poin Hadiah', Message: 'Anda mendapatkan 150 poin dari pembelian terakhir!', IsRead: false },
      ]);
    }

    if (custMap['CUST-002']) {
      const cid = custMap['CUST-002'];

      await trx('CustomerAddress').insert([
        { AddressID: uuidv7(), CustomerID: cid, Label: 'Rumah', ReceiverName: 'Siti Rahayu', Phone: '0813-2222222', Address: 'Jl. Kemanggisan No. 5, Jakarta', DefaultAddress: true },
      ]);

      if (itemMap['SNK-001']) {
        await trx('CustomerFavorite').insert([
          { FavoriteID: uuidv7(), CustomerID: cid, ItemID: itemMap['SNK-001'] },
          { FavoriteID: uuidv7(), CustomerID: cid, ItemID: itemMap['KOP-002'] },
        ]);
      }

      await trx('CustomerNotification').insert([
        { NotificationID: uuidv7(), CustomerID: cid, Title: 'Promo Spesial', Message: 'Beli 1 gratis 1 untuk semua menu Kopi!', IsRead: false },
      ]);
    }

    const prom1 = uuidv7();
    const prom2 = uuidv7();

    await trx('Promotion').insert([
      { PromotionID: prom1, PromotionName: 'Beli 2 Gratis 1 Nasi Goreng', Description: 'Beli 2 Nasi Goreng Spesial gratis 1', StartDate: '2025-01-01', EndDate: '2025-12-31', MinimumPurchase: 50000, MaximumDiscount: 25000, PromotionType: 'BuyXFreeY', DiscountType: 'Nominal', DiscountValue: 25000, BuyQty: 2, FreeQty: 1, Priority: 1, IsActive: true },
      { PromotionID: prom2, PromotionName: 'Diskon Kopi Sore 20%', Description: 'Diskon 20% untuk semua menu Kopi mulai jam 15:00-17:00', StartDate: '2025-01-01', EndDate: '2025-12-31', MinimumPurchase: 0, MaximumDiscount: 10000, PromotionType: 'ItemDiscount', DiscountType: 'Percentage', DiscountValue: 20.00, Priority: 2, IsActive: true },
    ]);

    if (itemMap['MKN-001']) {
      await trx('PromotionItem').insert([
        { PromotionItemID: uuidv7(), PromotionID: prom1, ItemID: itemMap['MKN-001'] },
      ]);
    }
    if (itemMap['KOP-001']) {
      await trx('PromotionItem').insert([
        { PromotionItemID: uuidv7(), PromotionID: prom2, ItemID: itemMap['KOP-001'] },
        { PromotionItemID: uuidv7(), PromotionID: prom2, ItemID: itemMap['KOP-002'] },
        { PromotionItemID: uuidv7(), PromotionID: prom2, ItemID: itemMap['KOP-003'] },
      ]);
    }

    console.log('04_crm_promotion: CRM & Promotion data seeded successfully');
    console.log('  CustomerAddress: 3, CustomerFavorite: 5, CustomerCart: 2, CustomerNotification: 3');
    console.log('  Promotions: 2, PromotionItems: 4');
  });
};
