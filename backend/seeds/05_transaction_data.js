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
  const existing = await knex('Order').first();
  if (existing) {
    console.log('05_transaction: Transaction data already exists, skipping');
    return;
  }

  const items = await knex('Item').select('ItemID', 'ItemCode', 'ItemName', 'Price');
  const itemMap = {};
  for (const it of items) {
    itemMap[it.ItemCode] = it;
  }

  const tables = await knex('Table').where('BranchID', BRANCH_ID).select('TableID', 'TableCode');
  const tableMap = {};
  for (const t of tables) {
    tableMap[t.TableCode] = t.TableID;
  }

  const payMethods = await knex('PaymentMethod').select('PaymentMethodID', 'MethodCode');
  const payMap = {};
  for (const p of payMethods) {
    payMap[p.MethodCode] = p.PaymentMethodID;
  }

  const discounts = await knex('Discount').where('DiscountName', 'Diskon Member 10%').first();
  const vouchers = await knex('Voucher').where('VoucherCode', 'WELCOME10').first();
  const customers = await knex('MstCustomer').select('CustomerID', 'CustomerCode');
  const custMap = {};
  for (const c of customers) {
    custMap[c.CustomerCode] = c.CustomerID;
  }

  const modifiers = await knex('Modifier').select('ModifierID', 'ModifierName');
  const modMap = {};
  for (const m of modifiers) {
    modMap[m.ModifierName] = m.ModifierID;
  }

  const modOpts = await knex('ModifierOption').select('ModifierOptionID', 'ModifierID', 'OptionName', 'AdditionalPrice');
  const findModOpt = (modName, optName) => {
    const modId = modMap[modName];
    if (!modId) return null;
    return modOpts.find(o => o.ModifierID === modId && o.OptionName === optName) || null;
  };

  const USER_IDS = {
    ADMIN: '00000000-0000-0000-0000-000000000001',
    OWNER: '00000000-0000-0000-0000-000000000002',
    MANAGER: '00000000-0000-0000-0000-000000000003',
    CASHIER: '00000000-0000-0000-0000-000000000004',
    KITCHEN: '00000000-0000-0000-0000-000000000005',
  };

  await knex.transaction(async (trx) => {
    const now = new Date();
    const h = (n) => new Date(now.getFullYear(), now.getMonth(), now.getDate(), n, 0, 0);

    const userKasir = USER_IDS.CASHIER;
    const userAdmin = USER_IDS.ADMIN;

    // ==================== ORDER 1: Completed, Cash, by Cashier, Customer Budi, Meja 01 ====================
    const order1Id = uuidv7();
    const od1Items = [
      { ItemCode: 'MKN-001', Qty: 2, Note: 'Pedas sedang' },
      { ItemCode: 'MIN-001', Qty: 2 },
      { ItemCode: 'DST-001', Qty: 1 },
    ];
    const subTotal1 = od1Items.reduce((sum, od) => sum + (itemMap[od.ItemCode]?.Price || 0) * od.Qty, 0);
    const discountTotal1 = Math.round(subTotal1 * 0.10);
    const taxTotal1 = Math.round((subTotal1 - discountTotal1) * 0.11);
    const grandTotal1 = subTotal1 - discountTotal1 + taxTotal1;

    await trx('Order').insert({
      OrderID: order1Id, BranchID: BRANCH_ID, CustomerID: custMap['CUST-001'] || null,
      TableID: tableMap['M01'] || null, UserID: userKasir, OrderNumber: 'ORD-2025-0001',
      OrderType: 'DineIn', Status: 'Completed', SubTotal: subTotal1,
      DiscountTotal: discountTotal1, TaxTotal: taxTotal1, ServiceCharge: 0,
      GrandTotal: grandTotal1, PaymentStatus: 'Paid', Note: '',
      CreatedAt: h(10), UpdatedAt: h(10),
    });

    for (const od of od1Items) {
      const item = itemMap[od.ItemCode];
      if (!item) continue;
      const odId = uuidv7();
      await trx('OrderDetail').insert({
        OrderDetailID: odId, OrderID: order1Id, ItemID: item.ItemID,
        ItemName: item.ItemName, Qty: od.Qty, Price: item.Price,
        SubTotal: item.Price * od.Qty, Note: od.Note || '',
      });

      if (od.ItemCode === 'MKN-001') {
        const pedasOpt = findModOpt('Level Pedas', 'Pedas Sedang');
        if (pedasOpt) {
          await trx('OrderModifier').insert({
            OrderModifierID: uuidv7(), OrderDetailID: odId,
            ModifierID: modMap['Level Pedas'], ModifierOptionID: pedasOpt.ModifierOptionID,
            OptionName: 'Pedas Sedang', AdditionalPrice: 0,
          });
        }
        const ukuranOpt = findModOpt('Ukuran', 'Regular');
        if (ukuranOpt) {
          await trx('OrderModifier').insert({
            OrderModifierID: uuidv7(), OrderDetailID: odId,
            ModifierID: modMap['Ukuran'], ModifierOptionID: ukuranOpt.ModifierOptionID,
            OptionName: 'Regular', AdditionalPrice: 0,
          });
        }
      }

      if (od.ItemCode === 'DST-001') {
        const toppingOpt = findModOpt('Topping', 'Choco Chip');
        if (toppingOpt) {
          await trx('OrderModifier').insert({
            OrderModifierID: uuidv7(), OrderDetailID: odId,
            ModifierID: modMap['Topping'], ModifierOptionID: toppingOpt.ModifierOptionID,
            OptionName: 'Choco Chip', AdditionalPrice: toppingOpt.AdditionalPrice || 0,
          });
        }
      }

      await trx('Kitchen').insert({
        KitchenID: uuidv7(), OrderID: order1Id, OrderDetailID: odId,
        ItemName: item.ItemName, Qty: od.Qty, Status: 'Completed',
        Note: od.Note || '', CreatedAt: h(10), UpdatedAt: h(10),
      });
    }

    if (discounts) {
      await trx('OrderDiscount').insert({
        OrderDiscountID: uuidv7(), OrderID: order1Id,
        DiscountID: discounts.DiscountID, DiscountName: discounts.DiscountName,
        DiscountType: discounts.DiscountType, DiscountValue: discounts.DiscountValue,
        DiscountAmount: discountTotal1,
      });
    }

    await trx('Payment').insert({
      PaymentID: uuidv7(), OrderID: order1Id,
      PaymentMethodID: payMap['CASH'] || null, PaymentAmount: grandTotal1,
      ReferenceNumber: 'TRX-0001',
    });

    if (tableMap['M01']) {
      await trx('TableHistory').insert({
        TableHistoryID: uuidv7(), TableID: tableMap['M01'],
        OrderID: order1Id, StartTime: h(10), EndTime: h(11),
      });
    }

    if (custMap['CUST-001']) {
      await trx('PointHistory').insert({
        PointHistoryID: uuidv7(), CustomerID: custMap['CUST-001'],
        OrderID: order1Id, Point: Math.floor(grandTotal1 / 1000),
        Type: 'Earn', Reference: 'Pembelian Order #ORD-2025-0001',
      });
    }

    // ==================== ORDER 2: Completed, QRIS, Walk-in, Meja 03 ====================
    const order2Id = uuidv7();
    const od2Items = [
      { ItemCode: 'MKN-003', Qty: 1 },
      { ItemCode: 'MKN-005', Qty: 1 },
      { ItemCode: 'MIN-003', Qty: 1 },
      { ItemCode: 'SNK-001', Qty: 2 },
    ];
    const subTotal2 = od2Items.reduce((sum, od) => sum + (itemMap[od.ItemCode]?.Price || 0) * od.Qty, 0);
    const taxTotal2 = Math.round(subTotal2 * 0.11);
    const grandTotal2 = subTotal2 + taxTotal2;

    await trx('Order').insert({
      OrderID: order2Id, BranchID: BRANCH_ID, CustomerID: null,
      TableID: tableMap['M03'] || null, UserID: userKasir, OrderNumber: 'ORD-2025-0002',
      OrderType: 'DineIn', Status: 'Completed', SubTotal: subTotal2,
      DiscountTotal: 0, TaxTotal: taxTotal2, ServiceCharge: 0,
      GrandTotal: grandTotal2, PaymentStatus: 'Paid', Note: '',
      CreatedAt: h(12), UpdatedAt: h(12),
    });

    for (const od of od2Items) {
      const item = itemMap[od.ItemCode];
      if (!item) continue;
      const odId = uuidv7();
      await trx('OrderDetail').insert({
        OrderDetailID: odId, OrderID: order2Id, ItemID: item.ItemID,
        ItemName: item.ItemName, Qty: od.Qty, Price: item.Price,
        SubTotal: item.Price * od.Qty, Note: od.Note || '',
      });

      if (od.ItemCode === 'MKN-003') {
        const ukuranOpt = findModOpt('Ukuran', 'Large');
        if (ukuranOpt) {
          await trx('OrderModifier').insert({
            OrderModifierID: uuidv7(), OrderDetailID: odId,
            ModifierID: modMap['Ukuran'], ModifierOptionID: ukuranOpt.ModifierOptionID,
            OptionName: 'Large', AdditionalPrice: ukuranOpt.AdditionalPrice || 0,
          });
        }
      }

      await trx('Kitchen').insert({
        KitchenID: uuidv7(), OrderID: order2Id, OrderDetailID: odId,
        ItemName: item.ItemName, Qty: od.Qty, Status: 'Completed',
        Note: od.Note || '', CreatedAt: h(12), UpdatedAt: h(12),
      });
    }

    await trx('Payment').insert({
      PaymentID: uuidv7(), OrderID: order2Id,
      PaymentMethodID: payMap['QRIS'] || null, PaymentAmount: grandTotal2,
      ReferenceNumber: 'TRX-0002',
    });

    if (tableMap['M03']) {
      await trx('TableHistory').insert({
        TableHistoryID: uuidv7(), TableID: tableMap['M03'],
        OrderID: order2Id, StartTime: h(12), EndTime: h(13),
      });
    }

    // ==================== ORDER 3: In Progress, Unpaid, Admin, Customer Ahmad, Meja 05 ====================
    const order3Id = uuidv7();
    const od3Items = [
      { ItemCode: 'MKN-004', Qty: 1 },
      { ItemCode: 'MIN-005', Qty: 2 },
      { ItemCode: 'SNK-003', Qty: 1 },
    ];
    const subTotal3 = od3Items.reduce((sum, od) => sum + (itemMap[od.ItemCode]?.Price || 0) * od.Qty, 0);
    const taxTotal3 = Math.round(subTotal3 * 0.11);
    const grandTotal3 = subTotal3 + taxTotal3;

    await trx('Order').insert({
      OrderID: order3Id, BranchID: BRANCH_ID, CustomerID: custMap['CUST-003'] || null,
      TableID: tableMap['M05'] || null, UserID: userAdmin, OrderNumber: 'ORD-2025-0003',
      OrderType: 'DineIn', Status: 'InProgress', SubTotal: subTotal3,
      DiscountTotal: 0, TaxTotal: taxTotal3, ServiceCharge: 0,
      GrandTotal: grandTotal3, PaymentStatus: 'Unpaid', Note: '',
      CreatedAt: h(14), UpdatedAt: h(14),
    });

    for (const od of od3Items) {
      const item = itemMap[od.ItemCode];
      if (!item) continue;
      const odId = uuidv7();
      await trx('OrderDetail').insert({
        OrderDetailID: odId, OrderID: order3Id, ItemID: item.ItemID,
        ItemName: item.ItemName, Qty: od.Qty, Price: item.Price,
        SubTotal: item.Price * od.Qty, Note: od.Note || '',
      });

      await trx('Kitchen').insert({
        KitchenID: uuidv7(), OrderID: order3Id, OrderDetailID: odId,
        ItemName: item.ItemName, Qty: od.Qty, Status: 'Pending',
        Note: od.Note || '', CreatedAt: h(14), UpdatedAt: h(14),
      });
    }

    if (tableMap['M05']) {
      await trx('TableHistory').insert({
        TableHistoryID: uuidv7(), TableID: tableMap['M05'],
        OrderID: order3Id, StartTime: h(14), EndTime: null,
      });
    }

    // ==================== ORDER 4: Completed, GoPay, Customer Siti, Takeaway ====================
    const order4Id = uuidv7();
    const od4Items = [
      { ItemCode: 'KOP-002', Qty: 2 },
      { ItemCode: 'SNK-001', Qty: 1 },
    ];
    const subTotal4 = od4Items.reduce((sum, od) => sum + (itemMap[od.ItemCode]?.Price || 0) * od.Qty, 0);
    const taxTotal4 = Math.round(subTotal4 * 0.11);
    const grandTotal4 = subTotal4 + taxTotal4;

    await trx('Order').insert({
      OrderID: order4Id, BranchID: BRANCH_ID, CustomerID: custMap['CUST-002'] || null,
      TableID: null, UserID: userKasir, OrderNumber: 'ORD-2025-0004',
      OrderType: 'Takeaway', Status: 'Completed', SubTotal: subTotal4,
      DiscountTotal: 0, TaxTotal: taxTotal4, ServiceCharge: 0,
      GrandTotal: grandTotal4, PaymentStatus: 'Paid', Note: 'Bungkus',
      CreatedAt: h(15), UpdatedAt: h(15),
    });

    for (const od of od4Items) {
      const item = itemMap[od.ItemCode];
      if (!item) continue;
      const odId = uuidv7();
      await trx('OrderDetail').insert({
        OrderDetailID: odId, OrderID: order4Id, ItemID: item.ItemID,
        ItemName: item.ItemName, Qty: od.Qty, Price: item.Price,
        SubTotal: item.Price * od.Qty, Note: '',
      });

      await trx('Kitchen').insert({
        KitchenID: uuidv7(), OrderID: order4Id, OrderDetailID: odId,
        ItemName: item.ItemName, Qty: od.Qty, Status: 'Completed',
        Note: '', CreatedAt: h(15), UpdatedAt: h(15),
      });
    }

    await trx('Payment').insert({
      PaymentID: uuidv7(), OrderID: order4Id,
      PaymentMethodID: payMap['GOPAY'] || null, PaymentAmount: grandTotal4,
      ReferenceNumber: 'TRX-0004',
    });

    if (custMap['CUST-002']) {
      await trx('VoucherHistory').insert({
        VoucherHistoryID: uuidv7(), VoucherID: vouchers?.VoucherID || null,
        OrderID: order4Id, CustomerID: custMap['CUST-002'],
        VoucherCode: 'WELCOME10', DiscountAmount: Math.round(subTotal4 * 0.10),
      });

      await trx('PointHistory').insert({
        PointHistoryID: uuidv7(), CustomerID: custMap['CUST-002'],
        OrderID: order4Id, Point: Math.floor(grandTotal4 / 1000),
        Type: 'Earn', Reference: 'Pembelian Order #ORD-2025-0004',
      });
    }

    console.log('05_transaction: Transaction data seeded successfully');
    console.log('  Orders: 4, OrderDetails: 10, OrderModifiers: 3');
    console.log('  Payments: 3, Kitchen: 10, TableHistory: 3');
    console.log('  VoucherHistory: 1, PointHistory: 2, OrderDiscount: 1');
  });
};
