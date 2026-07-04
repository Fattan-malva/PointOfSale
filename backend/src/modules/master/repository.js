const db = require('../../db');
const uuidv7 = require('../../helpers/uuidv7');

class MasterRepository {
  async findAllCategory({ limit, offset, search } = {}) {
    let query = db('Category').select('*').orderBy('SortOrder');
    if (search) query = query.where(function () {
      this.where('CategoryName', 'like', `%${search}%`)
          .orWhere('Description', 'like', `%${search}%`);
    });
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllCategory({ search } = {}) {
    let query = db('Category');
    if (search) query = query.where(function () {
      this.where('CategoryName', 'like', `%${search}%`)
          .orWhere('Description', 'like', `%${search}%`);
    });
    return query.count('CategoryID as total').first();
  }

  async findCategoryById(id) {
    return db('Category').where('CategoryID', id).first();
  }

  async createCategory(data) {
    data.CategoryID = uuidv7();
    const maxSort = await db('Category').max('SortOrder').first();
    data.SortOrder = (maxSort?.SortOrder || 0) + 1;
    await db('Category').insert(data);
    return this.findCategoryById(data.CategoryID);
  }

  async updateCategory(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Category').where('CategoryID', id).update(data);
    return this.findCategoryById(id);
  }

  async deleteCategory(id) {
    return db('Category').where('CategoryID', id).del();
  }

  async findAllItem({ limit, offset, search, categoryId, itemType, branchId, includeGlobal = true } = {}) {
    let query = db('Item')
      .leftJoin('Category', 'Item.CategoryID', 'Category.CategoryID')
      .select('Item.*', 'Category.CategoryName')
      .orderBy('Item.ItemName');

    if (branchId) {
      query = query
        .leftJoin('ItemBranch as ib', 'Item.ItemID', 'ib.ItemID')
        .where(function () {
          this.where('ib.BranchID', branchId);
          if (includeGlobal) this.orWhereNotExists(db('ItemBranch').select('*').whereRaw('ItemBranch.ItemID = Item.ItemID'));
        })
        .groupBy('Item.ItemID', 'Category.CategoryName');
    }

    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    if (search) query = query.where(function () {
      this.where('Item.ItemName', 'like', `%${search}%`)
          .orWhere('Item.ItemCode', 'like', `%${search}%`);
    });
    if (categoryId) query = query.where('Item.CategoryID', categoryId);
    if (itemType) query = query.where('Item.ItemType', itemType);
    return query;
  }

  async countAllItem({ search, categoryId, itemType, branchId, includeGlobal = true } = {}) {
    let query = db('Item');
    if (branchId) {
      query = query
        .leftJoin('ItemBranch as ib', 'Item.ItemID', 'ib.ItemID')
        .where(function () {
          this.where('ib.BranchID', branchId);
          if (includeGlobal) this.orWhereNotExists(db('ItemBranch').select('*').whereRaw('ItemBranch.ItemID = Item.ItemID'));
        });
    }
    if (search) query = query.where(function () {
      this.where('ItemName', 'like', `%${search}%`)
          .orWhere('ItemCode', 'like', `%${search}%`);
    });
    if (categoryId) query = query.where('CategoryID', categoryId);
    if (itemType) query = query.where('ItemType', itemType);
    return query.count('ItemID as total').first();
  }

  async findItemById(id) {
    const item = await db('Item')
      .leftJoin('Category', 'Item.CategoryID', 'Category.CategoryID')
      .where('Item.ItemID', id)
      .select('Item.*', 'Category.CategoryName')
      .first();
    if (!item) return null;
    const taxes = await db('ItemTax')
      .leftJoin('Tax', 'ItemTax.TaxID', 'Tax.TaxID')
      .where('ItemTax.ItemID', id)
      .select('Tax.TaxID', 'Tax.TaxName', 'Tax.TaxRate');
    const discounts = await db('ItemDiscount')
      .leftJoin('Discount', 'ItemDiscount.DiscountID', 'Discount.DiscountID')
      .where('ItemDiscount.ItemID', id)
      .select('Discount.DiscountID', 'Discount.DiscountName', 'Discount.DiscountType', 'Discount.DiscountValue');
    const branches = await db('ItemBranch')
      .leftJoin('Branch', 'ItemBranch.BranchID', 'Branch.BranchID')
      .where('ItemBranch.ItemID', id)
      .select('Branch.BranchID', 'Branch.BranchCode', 'Branch.BranchName', 'ItemBranch.IsAvailable');
    return { ...item, Taxes: taxes, Discounts: discounts, Branches: branches };
  }

  async findItemsByCategoryId(categoryId) {
    return db('Item').where('CategoryID', categoryId).orderBy('ItemName');
  }

  async createItem(data) {
    data.ItemID = uuidv7();
    await db('Item').insert(data);
    return this.findItemById(data.ItemID);
  }

  async updateItem(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Item').where('ItemID', id).update(data);
    return this.findItemById(id);
  }

  async deleteItem(id) {
    return db('Item').where('ItemID', id).del();
  }

  async findTaxesByItemId(itemId) {
    return db('ItemTax')
      .leftJoin('Tax', 'ItemTax.TaxID', 'Tax.TaxID')
      .where('ItemTax.ItemID', itemId)
      .select('Tax.TaxID', 'Tax.TaxName', 'Tax.TaxRate', 'Tax.IsActive');
  }

  async assignTaxToItem(itemId, taxId) {
    const id = uuidv7();
    await db('ItemTax').insert({ ItemTaxID: id, ItemID: itemId, TaxID: taxId });
    return { ItemTaxID: id, ItemID: itemId, TaxID: taxId };
  }

  async removeTaxFromItem(itemId, taxId) {
    return db('ItemTax').where('ItemID', itemId).andWhere('TaxID', taxId).del();
  }

  async findDiscountsByItemId(itemId) {
    return db('ItemDiscount')
      .leftJoin('Discount', 'ItemDiscount.DiscountID', 'Discount.DiscountID')
      .where('ItemDiscount.ItemID', itemId)
      .select('Discount.DiscountID', 'Discount.DiscountName', 'Discount.DiscountType', 'Discount.DiscountValue', 'Discount.IsActive');
  }

  async assignDiscountToItem(itemId, discountId) {
    const id = uuidv7();
    await db('ItemDiscount').insert({ ItemDiscountID: id, ItemID: itemId, DiscountID: discountId });
    return { ItemDiscountID: id, ItemID: itemId, DiscountID: discountId };
  }

  async removeDiscountFromItem(itemId, discountId) {
    return db('ItemDiscount').where('ItemID', itemId).andWhere('DiscountID', discountId).del();
  }

  async findAllModifier({ limit, offset } = {}) {
    let query = db('Modifier').select('*').orderBy('ModifierName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllModifier() {
    return db('Modifier').count('ModifierID as total').first();
  }

  async findModifierById(id) {
    return db('Modifier').where('ModifierID', id).first();
  }

  async createModifier(data) {
    data.ModifierID = uuidv7();
    await db('Modifier').insert(data);
    return this.findModifierById(data.ModifierID);
  }

  async updateModifier(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Modifier').where('ModifierID', id).update(data);
    return this.findModifierById(id);
  }

  async deleteModifier(id) {
    return db('Modifier').where('ModifierID', id).del();
  }

  async findOptionsByModifierId(modifierId) {
    return db('ModifierOption').where('ModifierID', modifierId).orderBy('SortOrder');
  }

  async findModifierOptionById(id) {
    return db('ModifierOption').where('ModifierOptionID', id).first();
  }

  async createModifierOption(data) {
    data.ModifierOptionID = uuidv7();
    await db('ModifierOption').insert(data);
    return this.findModifierOptionById(data.ModifierOptionID);
  }

  async updateModifierOption(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('ModifierOption').where('ModifierOptionID', id).update(data);
    return this.findModifierOptionById(id);
  }

  async deleteModifierOption(id) {
    return db('ModifierOption').where('ModifierOptionID', id).del();
  }

  async findModifiersByItemId(itemId) {
    return db('ItemModifier as im')
      .join('Modifier as m', 'im.ModifierID', 'm.ModifierID')
      .where('im.ItemID', itemId)
      .select('m.*', 'im.SortOrder')
      .orderBy('im.SortOrder');
  }

  async assignModifierToItem(itemId, modifierId) {
    return db('ItemModifier').insert({
      ItemModifierID: uuidv7(),
      ItemID: itemId,
      ModifierID: modifierId,
    });
  }

  async removeModifierFromItem(itemId, modifierId) {
    return db('ItemModifier').where({ ItemID: itemId, ModifierID: modifierId }).del();
  }

  async findPackageDetails(packageItemId) {
    return db('PackageDetail')
      .join('Item', 'PackageDetail.ItemID', 'Item.ItemID')
      .where('PackageDetail.PackageItemID', packageItemId)
      .select('PackageDetail.*', 'Item.ItemName', 'Item.Price')
      .orderBy('PackageDetail.PackageDetailID');
  }

  async createPackageDetail(data) {
    data.PackageDetailID = uuidv7();
    await db('PackageDetail').insert(data);
    return db('PackageDetail').where('PackageDetailID', data.PackageDetailID).first();
  }

  async deletePackageDetail(id) {
    return db('PackageDetail').where('PackageDetailID', id).del();
  }

  async findAllTable({ limit, offset } = {}) {
    let query = db('Table')
      .join('Branch', 'Table.BranchID', 'Branch.BranchID')
      .select('Table.*', 'Branch.BranchName')
      .orderBy('Table.TableCode');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllTable() {
    return db('Table').count('TableID as total').first();
  }

  async findTableById(id) {
    return db('Table')
      .join('Branch', 'Table.BranchID', 'Branch.BranchID')
      .where('Table.TableID', id)
      .select('Table.*', 'Branch.BranchName')
      .first();
  }

  async findTablesByBranchId(branchId) {
    return db('Table').where('BranchID', branchId).orderBy('TableCode');
  }

  async createTable(data) {
    data.TableID = uuidv7();
    await db('Table').insert(data);
    return this.findTableById(data.TableID);
  }

  async updateTable(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Table').where('TableID', id).update(data);
    return this.findTableById(id);
  }

  async deleteTable(id) {
    return db('Table').where('TableID', id).del();
  }

  async findAllTax({ limit, offset } = {}) {
    let query = db('Tax').select('*').orderBy('TaxName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllTax() {
    return db('Tax').count('TaxID as total').first();
  }

  async findTaxById(id) {
    return db('Tax').where('TaxID', id).first();
  }

  async createTax(data) {
    data.TaxID = uuidv7();
    await db('Tax').insert(data);
    return this.findTaxById(data.TaxID);
  }

  async updateTax(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Tax').where('TaxID', id).update(data);
    return this.findTaxById(id);
  }

  async deleteTax(id) {
    return db('Tax').where('TaxID', id).del();
  }

  async findAllDiscount({ limit, offset } = {}) {
    let query = db('Discount').select('*').orderBy('DiscountName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllDiscount() {
    return db('Discount').count('DiscountID as total').first();
  }

  async findDiscountById(id) {
    return db('Discount').where('DiscountID', id).first();
  }

  async createDiscount(data) {
    data.DiscountID = uuidv7();
    await db('Discount').insert(data);
    return this.findDiscountById(data.DiscountID);
  }

  async updateDiscount(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Discount').where('DiscountID', id).update(data);
    return this.findDiscountById(id);
  }

  async deleteDiscount(id) {
    return db('Discount').where('DiscountID', id).del();
  }

  async findAllVoucher({ limit, offset } = {}) {
    let query = db('Voucher').select('*').orderBy('VoucherName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllVoucher() {
    return db('Voucher').count('VoucherID as total').first();
  }

  async findVoucherById(id) {
    return db('Voucher').where('VoucherID', id).first();
  }

  async findVoucherByCode(code) {
    return db('Voucher').where('VoucherCode', code).first();
  }

  async createVoucher(data) {
    data.VoucherID = uuidv7();
    await db('Voucher').insert(data);
    return this.findVoucherById(data.VoucherID);
  }

  async updateVoucher(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Voucher').where('VoucherID', id).update(data);
    return this.findVoucherById(id);
  }

  async deleteVoucher(id) {
    return db('Voucher').where('VoucherID', id).del();
  }

  async findAllPaymentMethod({ limit, offset } = {}) {
    let query = db('PaymentMethod').select('*').orderBy('MethodName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllPaymentMethod() {
    return db('PaymentMethod').count('PaymentMethodID as total').first();
  }

  async findPaymentMethodById(id) {
    return db('PaymentMethod').where('PaymentMethodID', id).first();
  }

  async createPaymentMethod(data) {
    data.PaymentMethodID = uuidv7();
    await db('PaymentMethod').insert(data);
    return this.findPaymentMethodById(data.PaymentMethodID);
  }

  async updatePaymentMethod(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('PaymentMethod').where('PaymentMethodID', id).update(data);
    return this.findPaymentMethodById(id);
  }

  async deletePaymentMethod(id) {
    return db('PaymentMethod').where('PaymentMethodID', id).del();
  }

  async findAllShift({ limit, offset } = {}) {
    let query = db('Shift').select('*').orderBy('StartTime');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllShift() {
    return db('Shift').count('ShiftID as total').first();
  }

  async findShiftById(id) {
    return db('Shift').where('ShiftID', id).first();
  }

  async createShift(data) {
    data.ShiftID = uuidv7();
    await db('Shift').insert(data);
    return this.findShiftById(data.ShiftID);
  }

  async updateShift(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Shift').where('ShiftID', id).update(data);
    return this.findShiftById(id);
  }

  async deleteShift(id) {
    return db('Shift').where('ShiftID', id).del();
  }

  async findAllCustomer({ limit, offset } = {}) {
    let query = db('MstCustomer').select('*').orderBy('FullName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllCustomer() {
    return db('MstCustomer').count('CustomerID as total').first();
  }

  async findCustomerById(id) {
    return db('MstCustomer').where('CustomerID', id).first();
  }

  async findCustomerByPhone(phone) {
    return db('MstCustomer').where('Phone', phone).first();
  }

  async createCustomer(data) {
    data.CustomerID = uuidv7();
    await db('MstCustomer').insert(data);
    return this.findCustomerById(data.CustomerID);
  }

  async updateCustomer(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('MstCustomer').where('CustomerID', id).update(data);
    return this.findCustomerById(id);
  }

  async deleteCustomer(id) {
    return db('MstCustomer').where('CustomerID', id).del();
  }

  async findAllMedia({ limit, offset } = {}) {
    let query = db('Media').select('*').orderBy('FileName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllMedia() {
    return db('Media').count('MediaID as total').first();
  }

  async findMediaById(id) {
    return db('Media').where('MediaID', id).first();
  }

  async createMedia(data) {
    data.MediaID = uuidv7();
    await db('Media').insert(data);
    return this.findMediaById(data.MediaID);
  }

  async deleteMedia(id) {
    return db('Media').where('MediaID', id).del();
  }

  async findMediaByItemId(itemId) {
    return db('ItemMedia as im')
      .join('Media as m', 'im.MediaID', 'm.MediaID')
      .where('im.ItemID', itemId)
      .select('m.*', 'im.SortOrder')
      .orderBy('im.SortOrder');
  }

  async assignMediaToItem(itemId, mediaId, sortOrder = 0) {
    return db('ItemMedia').insert({
      ItemMediaID: uuidv7(),
      ItemID: itemId,
      MediaID: mediaId,
      SortOrder: sortOrder,
    });
  }

  async removeMediaFromItem(itemId, mediaId) {
    return db('ItemMedia').where({ ItemID: itemId, MediaID: mediaId }).del();
  }

  async findBranchesByItemId(itemId) {
    return db('ItemBranch')
      .leftJoin('Branch', 'ItemBranch.BranchID', 'Branch.BranchID')
      .where('ItemBranch.ItemID', itemId)
      .select('Branch.BranchID', 'Branch.BranchCode', 'Branch.BranchName', 'Branch.IsActive', 'ItemBranch.IsAvailable');
  }

  async assignBranchToItem(itemId, branchId) {
    const id = uuidv7();
    await db('ItemBranch').insert({ ItemBranchID: id, ItemID: itemId, BranchID: branchId, IsAvailable: true });
    return { ItemBranchID: id, ItemID: itemId, BranchID: branchId };
  }

  async removeBranchFromItem(itemId, branchId) {
    return db('ItemBranch').where('ItemID', itemId).andWhere('BranchID', branchId).del();
  }
}

module.exports = MasterRepository;
