const MasterRepository = require('./repository');
const { auditLog } = require('../../helpers/audit');

class MasterService {
  constructor() {
    this.repo = new MasterRepository();
  }

  async getAllCategory(params = {}) {
    return this.repo.findAllCategory(params);
  }

  async countAllCategory(params = {}) {
    return this.repo.countAllCategory(params);
  }

  async getCategoryById(id) {
    const cat = await this.repo.findCategoryById(id);
    if (!cat) throw new Error('Category not found');
    return cat;
  }

  async createCategory(data) {
    return this.repo.createCategory(data);
  }

  async updateCategory(id, data) {
    await this.getCategoryById(id);
    return this.repo.updateCategory(id, data);
  }

  async deleteCategory(id) {
    await this.getCategoryById(id);
    const items = await this.repo.findItemsByCategoryId(id);
    if (items.length > 0) {
      throw new Error(`Cannot delete category: ${items.length} item(s) are still using this category`);
    }
    return this.repo.deleteCategory(id);
  }

  async getAllItem(params = {}) {
    return this.repo.findAllItem(params);
  }

  async countAllItem(params = {}) {
    return this.repo.countAllItem(params);
  }

  async getItemById(id) {
    const item = await this.repo.findItemById(id);
    if (!item) throw new Error('Item not found');
    return item;
  }

  async createItem(data) {
    // Support both payload field names:
    // - Items: array of package detail lines (expected by backend)
    // - details: alias produced by Flutter PackageModal
    const payload = { ...data };
    if (!Array.isArray(payload.Items) && Array.isArray(payload.details)) {
      payload.Items = payload.details;
    }

    const { branchIds, taxIds, discountIds, Items, ...itemData } = payload;
    const item = await this.repo.createItem(itemData);

    if (Array.isArray(branchIds)) {
      for (const branchId of branchIds) {
        await this.repo.assignBranchToItem(item.ItemID, branchId);
      }
    }
    if (Array.isArray(taxIds)) {
      for (const taxId of taxIds) {
        await this.repo.assignTaxToItem(item.ItemID, taxId);
      }
    }
    if (Array.isArray(discountIds)) {
      for (const discountId of discountIds) {
        await this.repo.assignDiscountToItem(item.ItemID, discountId);
      }
    }

    // Process PackageDetails for Package items
    if (itemData.ItemType === 'Package' && Array.isArray(Items)) {
      for (const detail of Items) {
        await this.repo.createPackageDetail({
          PackageItemID: item.ItemID,
          ItemID: detail.ItemID,
          Qty: detail.Qty,
          UnitPrice: detail.UnitPrice,
        });
      }
    }

    await auditLog({
      Module: 'Master', Action: 'CreateItem', TableName: 'Item',
      RecordID: item.ItemID,
      NewValue: { ItemCode: item.ItemCode, ItemName: item.ItemName, Price: item.Price },
    });

    return this.repo.findItemById(item.ItemID);
  }

  async updateItem(id, data) {
    // Support both payload field names:
    // - Items: array of package detail lines (expected by backend)
    // - details: alias produced by Flutter PackageModal
    const payload = { ...data };
    if (!Array.isArray(payload.Items) && Array.isArray(payload.details)) {
      payload.Items = payload.details;
    }

    const {
      branchIds,
      taxIds,
      discountIds,
      Items,
      details, // ignore alias after mapping
      ...itemData
    } = payload;

    // Items drives package-detail processing only; must NOT be written to Item table.
    // So we never include Items/details in `itemData`.
    const old = await this.getItemById(id);
    await this.repo.updateItem(id, itemData);

    if (Array.isArray(branchIds)) {
      const current = await this.repo.findBranchesByItemId(id);
      const currentIds = new Set(current.map(b => b.BranchID));
      const newIds = new Set(branchIds);

      for (const branchId of currentIds) {
        if (!newIds.has(branchId)) await this.repo.removeBranchFromItem(id, branchId);
      }
      for (const branchId of newIds) {
        if (!currentIds.has(branchId)) await this.repo.assignBranchToItem(id, branchId);
      }
    }

    if (Array.isArray(taxIds)) {
      const current = await this.repo.findTaxesByItemId(id);
      const currentIds = new Set(current.map(t => t.TaxID));
      const newIds = new Set(taxIds);

      // currentIds - newIds
      for (const taxId of currentIds) {
        if (!newIds.has(taxId)) {
          await this.repo.removeTaxFromItem(id, taxId);
        }
      }
      // newIds - currentIds
      for (const taxId of newIds) {
        if (!currentIds.has(taxId)) {
          await this.repo.assignTaxToItem(id, taxId);
        }
      }
    }

    if (Array.isArray(discountIds)) {
      const current = await this.repo.findDiscountsByItemId(id);
      const currentIds = new Set(current.map(d => d.DiscountID));
      const newIds = new Set(discountIds);

      // currentIds - newIds
      for (const discountId of currentIds) {
        if (!newIds.has(discountId)) {
          await this.repo.removeDiscountFromItem(id, discountId);
        }
      }
      // newIds - currentIds
      for (const discountId of newIds) {
        if (!currentIds.has(discountId)) {
          await this.repo.assignDiscountToItem(id, discountId);
        }
      }
    }

    // Process PackageDetails for Package items
    if (old.ItemType === 'Package' && Array.isArray(Items)) {
      const existing = await this.repo.findPackageDetails(id);
      for (const existingDetail of existing) {
        await this.repo.deletePackageDetail(existingDetail.PackageDetailID);
      }
      for (const detail of Items) {
        await this.repo.createPackageDetail({
          PackageItemID: id,
          ItemID: detail.ItemID,
          Qty: detail.Qty,
          UnitPrice: detail.UnitPrice,
        });
      }
    }

    await auditLog({
      Module: 'Master',
      Action: 'UpdateItem',
      TableName: 'Item',
      RecordID: id,
      OldValue: { ItemName: old.ItemName, Price: old.Price },
      NewValue: itemData,
    });

    return this.repo.findItemById(id);
  }

  async deleteItem(id) {
    const old = await this.getItemById(id);
    await this.repo.deleteItem(id);

    await auditLog({
      Module: 'Master', Action: 'DeleteItem', TableName: 'Item',
      RecordID: id,
      OldValue: { ItemCode: old.ItemCode, ItemName: old.ItemName },
    });
  }

  async getTaxesByItemId(itemId) {
    await this.getItemById(itemId);
    return this.repo.findTaxesByItemId(itemId);
  }

  async assignTaxToItem(itemId, taxId) {
    await this.getItemById(itemId);
    const tax = await this.repo.findTaxById(taxId);
    if (!tax) throw new Error('Tax not found');
    return this.repo.assignTaxToItem(itemId, taxId);
  }

  async removeTaxFromItem(itemId, taxId) {
    await this.getItemById(itemId);
    return this.repo.removeTaxFromItem(itemId, taxId);
  }

  async getDiscountsByItemId(itemId) {
    await this.getItemById(itemId);
    return this.repo.findDiscountsByItemId(itemId);
  }

  async assignDiscountToItem(itemId, discountId) {
    await this.getItemById(itemId);
    const discount = await this.repo.findDiscountById(discountId);
    if (!discount) throw new Error('Discount not found');
    return this.repo.assignDiscountToItem(itemId, discountId);
  }

  async removeDiscountFromItem(itemId, discountId) {
    await this.getItemById(itemId);
    return this.repo.removeDiscountFromItem(itemId, discountId);
  }

  async getAllModifier(params = {}) {
    return this.repo.findAllModifier(params);
  }

  async countAllModifier() {
    return this.repo.countAllModifier();
  }

  async getModifierById(id) {
    const mod = await this.repo.findModifierById(id);
    if (!mod) throw new Error('Modifier not found');
    return mod;
  }

  async createModifier(data) {
    return this.repo.createModifier(data);
  }

  async updateModifier(id, data) {
    await this.getModifierById(id);
    return this.repo.updateModifier(id, data);
  }

  async deleteModifier(id) {
    await this.getModifierById(id);
    return this.repo.deleteModifier(id);
  }

  async getOptionsByModifierId(modifierId) {
    await this.getModifierById(modifierId);
    return this.repo.findOptionsByModifierId(modifierId);
  }

  async createModifierOption(data) {
    return this.repo.createModifierOption(data);
  }

  async updateModifierOption(id, data) {
    const opt = await this.repo.findModifierOptionById(id);
    if (!opt) throw new Error('ModifierOption not found');
    return this.repo.updateModifierOption(id, data);
  }

  async deleteModifierOption(id) {
    const opt = await this.repo.findModifierOptionById(id);
    if (!opt) throw new Error('ModifierOption not found');
    return this.repo.deleteModifierOption(id);
  }

  async getModifiersByItemId(itemId) {
    await this.getItemById(itemId);
    return this.repo.findModifiersByItemId(itemId);
  }

  async assignModifierToItem(itemId, modifierId) {
    await this.getItemById(itemId);
    await this.getModifierById(modifierId);
    return this.repo.assignModifierToItem(itemId, modifierId);
  }

  async removeModifierFromItem(itemId, modifierId) {
    await this.getItemById(itemId);
    await this.getModifierById(modifierId);
    return this.repo.removeModifierFromItem(itemId, modifierId);
  }

  async getPackageDetails(packageItemId) {
    await this.getItemById(packageItemId);
    return this.repo.findPackageDetails(packageItemId);
  }

  async createPackageDetail(data) {
    return this.repo.createPackageDetail(data);
  }

  async deletePackageDetail(id) {
    return this.repo.deletePackageDetail(id);
  }

  async getAllTable(params = {}) {
    return this.repo.findAllTable(params);
  }

  async countAllTable() {
    return this.repo.countAllTable();
  }

  async getTableById(id) {
    const t = await this.repo.findTableById(id);
    if (!t) throw new Error('Table not found');
    return t;
  }

  async createTable(data) {
    return this.repo.createTable(data);
  }

  async updateTable(id, data) {
    await this.getTableById(id);
    return this.repo.updateTable(id, data);
  }

  async deleteTable(id) {
    await this.getTableById(id);
    return this.repo.deleteTable(id);
  }

  async getAllTax(params = {}) {
    return this.repo.findAllTax(params);
  }

  async countAllTax() {
    return this.repo.countAllTax();
  }

  async getTaxById(id) {
    const t = await this.repo.findTaxById(id);
    if (!t) throw new Error('Tax not found');
    return t;
  }

  async createTax(data) {
    return this.repo.createTax(data);
  }

  async updateTax(id, data) {
    await this.getTaxById(id);
    return this.repo.updateTax(id, data);
  }

  async deleteTax(id) {
    await this.getTaxById(id);
    return this.repo.deleteTax(id);
  }

  async getAllDiscount(params = {}) {
    return this.repo.findAllDiscount(params);
  }

  async countAllDiscount() {
    return this.repo.countAllDiscount();
  }

  async getDiscountById(id) {
    const d = await this.repo.findDiscountById(id);
    if (!d) throw new Error('Discount not found');
    return d;
  }

  async createDiscount(data) {
    return this.repo.createDiscount(data);
  }

  async updateDiscount(id, data) {
    await this.getDiscountById(id);
    return this.repo.updateDiscount(id, data);
  }

  async deleteDiscount(id) {
    await this.getDiscountById(id);
    return this.repo.deleteDiscount(id);
  }

  async getAllVoucher(params = {}) {
    return this.repo.findAllVoucher(params);
  }

  async countAllVoucher() {
    return this.repo.countAllVoucher();
  }

  async getVoucherById(id) {
    const v = await this.repo.findVoucherById(id);
    if (!v) throw new Error('Voucher not found');
    return v;
  }

  async createVoucher(data) {
    return this.repo.createVoucher(data);
  }

  async updateVoucher(id, data) {
    await this.getVoucherById(id);
    return this.repo.updateVoucher(id, data);
  }

  async deleteVoucher(id) {
    await this.getVoucherById(id);
    return this.repo.deleteVoucher(id);
  }

  async getAllPaymentMethod(params = {}) {
    return this.repo.findAllPaymentMethod(params);
  }

  async countAllPaymentMethod() {
    return this.repo.countAllPaymentMethod();
  }

  async getPaymentMethodById(id) {
    const pm = await this.repo.findPaymentMethodById(id);
    if (!pm) throw new Error('PaymentMethod not found');
    return pm;
  }

  async createPaymentMethod(data) {
    return this.repo.createPaymentMethod(data);
  }

  async updatePaymentMethod(id, data) {
    await this.getPaymentMethodById(id);
    return this.repo.updatePaymentMethod(id, data);
  }

  async deletePaymentMethod(id) {
    await this.getPaymentMethodById(id);
    return this.repo.deletePaymentMethod(id);
  }

  async getAllShift(params = {}) {
    return this.repo.findAllShift(params);
  }

  async countAllShift() {
    return this.repo.countAllShift();
  }

  async getShiftById(id) {
    const s = await this.repo.findShiftById(id);
    if (!s) throw new Error('Shift not found');
    return s;
  }

  async createShift(data) {
    return this.repo.createShift(data);
  }

  async updateShift(id, data) {
    await this.getShiftById(id);
    return this.repo.updateShift(id, data);
  }

  async deleteShift(id) {
    await this.getShiftById(id);
    return this.repo.deleteShift(id);
  }

  async getAllCustomer(params = {}) {
    return this.repo.findAllCustomer(params);
  }

  async countAllCustomer() {
    return this.repo.countAllCustomer();
  }

  async getCustomerById(id) {
    const c = await this.repo.findCustomerById(id);
    if (!c) throw new Error('Customer not found');
    return c;
  }

  async createCustomer(data) {
    return this.repo.createCustomer(data);
  }

  async updateCustomer(id, data) {
    await this.getCustomerById(id);
    return this.repo.updateCustomer(id, data);
  }

  async deleteCustomer(id) {
    await this.getCustomerById(id);
    return this.repo.deleteCustomer(id);
  }

  async getAllMedia(params = {}) {
    return this.repo.findAllMedia(params);
  }

  async countAllMedia() {
    return this.repo.countAllMedia();
  }

  async getMediaById(id) {
    const m = await this.repo.findMediaById(id);
    if (!m) throw new Error('Media not found');
    return m;
  }

  async createMedia(data) {
    return this.repo.createMedia(data);
  }

  async deleteMedia(id) {
    await this.getMediaById(id);
    return this.repo.deleteMedia(id);
  }

  async getMediaByItemId(itemId) {
    await this.getItemById(itemId);
    return this.repo.findMediaByItemId(itemId);
  }

  async assignMediaToItem(itemId, mediaId, sortOrder) {
    await this.getItemById(itemId);
    await this.getMediaById(mediaId);
    return this.repo.assignMediaToItem(itemId, mediaId, sortOrder);
  }

  async removeMediaFromItem(itemId, mediaId) {
    await this.getItemById(itemId);
    await this.getMediaById(mediaId);
    return this.repo.removeMediaFromItem(itemId, mediaId);
  }
}

module.exports = MasterService;
