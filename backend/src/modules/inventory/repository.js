const db = require('../../db');
const uuidv7 = require('../../helpers/uuidv7');

class InventoryRepository {
  async findAllSupplier({ limit, offset } = {}) {
    let query = db('Supplier').select('*').orderBy('SupplierName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllSupplier() {
    return db('Supplier').count('SupplierID as total').first();
  }

  async findSupplierById(id) {
    return db('Supplier').where('SupplierID', id).first();
  }

  async createSupplier(data) {
    data.SupplierID = uuidv7();
    await db('Supplier').insert(data);
    return this.findSupplierById(data.SupplierID);
  }

  async updateSupplier(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Supplier').where('SupplierID', id).update(data);
    return this.findSupplierById(id);
  }

  async deleteSupplier(id) {
    return db('Supplier').where('SupplierID', id).del();
  }

  async findPurchaseById(id) {
    return db('Purchase')
      .join('Branch', 'Purchase.BranchID', 'Branch.BranchID')
      .leftJoin('Supplier', 'Purchase.SupplierID', 'Supplier.SupplierID')
      .where('Purchase.PurchaseID', id)
      .select('Purchase.*', 'Branch.BranchName', 'Supplier.SupplierName')
      .first();
  }

  async findAllPurchase(filters = {}) {
    let query = db('Purchase')
      .join('Branch', 'Purchase.BranchID', 'Branch.BranchID')
      .leftJoin('Supplier', 'Purchase.SupplierID', 'Supplier.SupplierID')
      .select('Purchase.*', 'Branch.BranchName', 'Supplier.SupplierName');

    if (filters.Status) query = query.where('Purchase.Status', filters.Status);
    if (filters.BranchID) query = query.where('Purchase.BranchID', filters.BranchID);
    if (filters.limit) query = query.limit(filters.limit);
    if (filters.offset) query = query.offset(filters.offset);

    return query.orderBy('Purchase.CreatedAt', 'desc');
  }

  async countAllPurchase(filters = {}) {
    let query = db('Purchase');
    if (filters.Status) query = query.where('Status', filters.Status);
    if (filters.BranchID) query = query.where('BranchID', filters.BranchID);
    return query.count('PurchaseID as total').first();
  }

  async createPurchase(data) {
    data.PurchaseID = uuidv7();
    await db('Purchase').insert(data);
    return this.findPurchaseById(data.PurchaseID);
  }

  async updatePurchase(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Purchase').where('PurchaseID', id).update(data);
    return this.findPurchaseById(id);
  }

  async findPurchaseDetails(purchaseId) {
    return db('PurchaseDetail')
      .join('Item', 'PurchaseDetail.ItemID', 'Item.ItemID')
      .where('PurchaseDetail.PurchaseID', purchaseId)
      .select('PurchaseDetail.*', 'Item.ItemName', 'Item.ItemCode')
      .orderBy('PurchaseDetail.CreatedAt');
  }

  async createPurchaseDetail(data) {
    data.PurchaseDetailID = uuidv7();
    await db('PurchaseDetail').insert(data);
    return db('PurchaseDetail').where('PurchaseDetailID', data.PurchaseDetailID).first();
  }

  async deletePurchaseDetail(id) {
    return db('PurchaseDetail').where('PurchaseDetailID', id).del();
  }

  async findStockByItemAndBranch(itemId, branchId) {
    return db('Stock').where({ ItemID: itemId, BranchID: branchId }).first();
  }

  async findAllStock(filters = {}) {
    let query = db('Stock')
      .join('Item', 'Stock.ItemID', 'Item.ItemID')
      .join('Branch', 'Stock.BranchID', 'Branch.BranchID')
      .select('Stock.*', 'Item.ItemName', 'Item.ItemCode', 'Branch.BranchName');

    if (filters.BranchID) query = query.where('Stock.BranchID', filters.BranchID);
    if (filters.LowStock) query = query.whereRaw('Stock.CurrentStock <= Stock.MinStock');
    if (filters.limit) query = query.limit(filters.limit);
    if (filters.offset) query = query.offset(filters.offset);

    return query.orderBy('Item.ItemName');
  }

  async countAllStock(filters = {}) {
    let query = db('Stock');
    if (filters.BranchID) query = query.where('BranchID', filters.BranchID);
    if (filters.LowStock) query = query.whereRaw('CurrentStock <= MinStock');
    return query.count('StockID as total').first();
  }

  async upsertStock(data) {
    const existing = await this.findStockByItemAndBranch(data.ItemID, data.BranchID);
    if (existing) {
      await db('Stock').where('StockID', existing.StockID).update({
        CurrentStock: data.CurrentStock,
        UpdatedAt: db.fn.now(),
      });
      return db('Stock').where('StockID', existing.StockID).first();
    }
    data.StockID = uuidv7();
    await db('Stock').insert(data);
    return db('Stock').where('StockID', data.StockID).first();
  }

  async findStockMovements(filters = {}) {
    let query = db('StockMovement')
      .join('Item', 'StockMovement.ItemID', 'Item.ItemID')
      .join('Branch', 'StockMovement.BranchID', 'Branch.BranchID')
      .select('StockMovement.*', 'Item.ItemName', 'Item.ItemCode', 'Branch.BranchName');

    if (filters.ItemID) query = query.where('StockMovement.ItemID', filters.ItemID);
    if (filters.BranchID) query = query.where('StockMovement.BranchID', filters.BranchID);
    if (filters.Type) query = query.where('StockMovement.Type', filters.Type);

    return query.orderBy('StockMovement.CreatedAt', 'desc');
  }

  async createStockMovement(data) {
    data.StockMovementID = uuidv7();
    await db('StockMovement').insert(data);
    return db('StockMovement').where('StockMovementID', data.StockMovementID).first();
  }

  async findRecipeByItemId(itemId) {
    return db('Recipe').where('ItemID', itemId).first();
  }

  async findRecipeById(id) {
    return db('Recipe')
      .join('Item', 'Recipe.ItemID', 'Item.ItemID')
      .where('Recipe.RecipeID', id)
      .select('Recipe.*', 'Item.ItemName', 'Item.ItemCode')
      .first();
  }

  async findAllRecipe({ limit, offset } = {}) {
    let query = db('Recipe')
      .join('Item', 'Recipe.ItemID', 'Item.ItemID')
      .select('Recipe.*', 'Item.ItemName', 'Item.ItemCode')
      .orderBy('Recipe.RecipeName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllRecipe() {
    return db('Recipe').count('RecipeID as total').first();
  }

  async createRecipe(data) {
    data.RecipeID = uuidv7();
    await db('Recipe').insert(data);
    return this.findRecipeById(data.RecipeID);
  }

  async updateRecipe(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Recipe').where('RecipeID', id).update(data);
    return this.findRecipeById(id);
  }

  async deleteRecipe(id) {
    return db('Recipe').where('RecipeID', id).del();
  }

  async findRecipeDetails(recipeId) {
    return db('RecipeDetail')
      .join('Item', 'RecipeDetail.ItemID', 'Item.ItemID')
      .where('RecipeDetail.RecipeID', recipeId)
      .select('RecipeDetail.*', 'Item.ItemName', 'Item.ItemCode')
      .orderBy('RecipeDetail.CreatedAt');
  }

  async createRecipeDetail(data) {
    data.RecipeDetailID = uuidv7();
    await db('RecipeDetail').insert(data);
    return db('RecipeDetail').where('RecipeDetailID', data.RecipeDetailID).first();
  }

  async deleteRecipeDetail(id) {
    return db('RecipeDetail').where('RecipeDetailID', id).del();
  }
}

module.exports = InventoryRepository;
