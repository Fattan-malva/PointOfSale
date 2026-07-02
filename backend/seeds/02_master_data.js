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
    const existingBranch = await trx('Branch').first();
    let branchId = existingBranch ? existingBranch.BranchID : null;
    if (!branchId) {
      branchId = uuidv7();
      await trx('Branch').insert({
        BranchID: branchId,
        BranchCode: 'MAIN',
        BranchName: 'Cabang Utama',
        Address: 'Jl. Contoh No. 1',
        Phone: '021-12345678',
        IsActive: true,
      });
    }

    const categories = ['Makanan', 'Minuman', 'Snack', 'Dessert'];
    for (let i = 0; i < categories.length; i++) {
      const existing = await trx('Category').where('CategoryName', categories[i]).first();
      if (!existing) {
        await trx('Category').insert({
          CategoryID: uuidv7(),
          CategoryName: categories[i],
          SortOrder: i + 1,
          IsActive: true,
        });
      }
    }

    const existingTax = await trx('Tax').first();
    if (!existingTax) {
      await trx('Tax').insert({
        TaxID: uuidv7(),
        TaxName: 'PPN 11%',
        TaxRate: 11.00,
        IsActive: true,
      });
    }

    const paymentMethods = [
      { MethodCode: 'CASH', MethodName: 'Tunai', MethodType: 'Cash' },
      { MethodCode: 'DEBIT', MethodName: 'Kartu Debit', MethodType: 'Card' },
      { MethodCode: 'QRIS', MethodName: 'QRIS', MethodType: 'QR' },
      { MethodCode: 'GOPAY', MethodName: 'GoPay', MethodType: 'E-Wallet' },
    ];
    for (const pm of paymentMethods) {
      const existing = await trx('PaymentMethod').where('MethodCode', pm.MethodCode).first();
      if (!existing) {
        await trx('PaymentMethod').insert({
          PaymentMethodID: uuidv7(),
          ...pm,
          IsActive: true,
        });
      }
    }

    const shifts = [
      { ShiftCode: 'PAGI', ShiftName: 'Pagi', StartTime: '07:00', EndTime: '15:00' },
      { ShiftCode: 'SIANG', ShiftName: 'Siang', StartTime: '15:00', EndTime: '23:00' },
    ];
    for (const s of shifts) {
      const existing = await trx('Shift').where('ShiftCode', s.ShiftCode).first();
      if (!existing) {
        await trx('Shift').insert({
          ShiftID: uuidv7(),
          ...s,
          IsActive: true,
        });
      }
    }

    const existingDiscount = await trx('Discount').first();
    if (!existingDiscount) {
      await trx('Discount').insert({
        DiscountID: uuidv7(),
        DiscountName: 'Diskon Member 10%',
        DiscountType: 'Percentage',
        DiscountValue: 10.00,
        IsActive: true,
      });
    }

    for (let i = 1; i <= 10; i++) {
      const code = `M${String(i).padStart(2, '0')}`;
      const existing = await trx('Table').where({ BranchID: branchId, TableCode: code }).first();
      if (!existing) {
        await trx('Table').insert({
          TableID: uuidv7(),
          BranchID: branchId,
          TableCode: code,
          TableName: `Meja ${i}`,
          Capacity: i <= 4 ? 2 : i <= 8 ? 4 : 6,
          IsActive: true,
        });
      }
    }
  });
};
