const InventoryRepository = require('./repository');

class InventoryService {
  constructor() {
    this.repo = new InventoryRepository();
  }

  async getAllSupplier() {
    return this.repo.findAllSupplier();
  }

  async getSupplierById(id) {
    const s = await this.repo.findSupplierById(id);
    if (!s) throw new Error('Supplier not found');
    return s;
  }

  async createSupplier(data) {
    return this.repo.createSupplier(data);
  }

  async updateSupplier(id, data) {
    await this.getSupplierById(id);
    return this.repo.updateSupplier(id, data);
  }

  async deleteSupplier(id) {
    await this.getSupplierById(id);
    return this.repo.deleteSupplier(id);
  }

  async getAllPurchase(filters) {
    return this.repo.findAllPurchase(filters);
  }

  async getPurchaseById(id) {
    const p = await this.repo.findPurchaseById(id);
    if (!p) throw new Error('Purchase not found');
    return p;
  }

  async getPurchaseWithDetails(id) {
    const purchase = await this.getPurchaseById(id);
    purchase.Items = await this.repo.findPurchaseDetails(id);
    return purchase;
  }

  async createPurchase(data) {
    const date = new Date();
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    const prefix = `PO-${y}${m}${d}-`;
    const all = await this.repo.findAllPurchase({});
    const todayPurchases = all.filter(p => p.PurchaseNumber && p.PurchaseNumber.startsWith(prefix));
    data.PurchaseNumber = prefix + String(todayPurchases.length + 1).padStart(4, '0');
    return this.repo.createPurchase(data);
  }

  async receivePurchase(id) {
    const purchase = await this.getPurchaseById(id);
    if (purchase.Status !== 'Ordered') throw new Error('Only ordered purchases can be received');
    const details = await this.repo.findPurchaseDetails(id);
    for (const d of details) {
      const stock = await this.repo.findStockByItemAndBranch(d.ItemID, purchase.BranchID);
      const currentStock = stock ? parseFloat(stock.CurrentStock) : 0;
      const newStock = currentStock + parseFloat(d.Qty);
      await this.repo.upsertStock({
        ItemID: d.ItemID,
        BranchID: purchase.BranchID,
        CurrentStock: newStock,
      });
      await this.repo.createStockMovement({
        ItemID: d.ItemID,
        BranchID: purchase.BranchID,
        Type: 'In',
        ReferenceType: 'Purchase',
        ReferenceID: id,
        Qty: d.Qty,
        StockBefore: currentStock,
        StockAfter: newStock,
      });
    }
    return this.repo.updatePurchase(id, { Status: 'Received' });
  }

  async addItemToPurchase(purchaseId, data) {
    const detail = await this.repo.createPurchaseDetail({
      PurchaseID: purchaseId,
      ItemID: data.ItemID,
      Qty: data.Qty,
      UnitCost: data.UnitCost,
      SubTotal: parseFloat(data.Qty) * parseFloat(data.UnitCost),
    });
    return detail;
  }

  async removeItemFromPurchase(purchaseId, detailId) {
    return this.repo.deletePurchaseDetail(detailId);
  }

  async getAllStock(filters) {
    return this.repo.findAllStock(filters);
  }

  async adjustStock(data) {
    const stock = await this.repo.findStockByItemAndBranch(data.ItemID, data.BranchID);
    const currentStock = stock ? parseFloat(stock.CurrentStock) : 0;
    const newStock = parseFloat(data.NewStock);
    await this.repo.upsertStock({
      ItemID: data.ItemID,
      BranchID: data.BranchID,
      CurrentStock: newStock,
    });
    await this.repo.createStockMovement({
      ItemID: data.ItemID,
      BranchID: data.BranchID,
      Type: 'Adjust',
      ReferenceType: 'StockAdjustment',
      Qty: newStock - currentStock,
      StockBefore: currentStock,
      StockAfter: newStock,
      Note: data.Note,
    });
    return this.repo.findStockByItemAndBranch(data.ItemID, data.BranchID);
  }

  async getStockMovements(filters) {
    return this.repo.findStockMovements(filters);
  }

  async getAllRecipe() {
    return this.repo.findAllRecipe();
  }

  async getRecipeById(id) {
    const r = await this.repo.findRecipeById(id);
    if (!r) throw new Error('Recipe not found');
    return r;
  }

  async getRecipeWithDetails(id) {
    const recipe = await this.getRecipeById(id);
    recipe.Ingredients = await this.repo.findRecipeDetails(id);
    return recipe;
  }

  async createRecipe(data) {
    return this.repo.createRecipe(data);
  }

  async updateRecipe(id, data) {
    await this.getRecipeById(id);
    return this.repo.updateRecipe(id, data);
  }

  async deleteRecipe(id) {
    await this.getRecipeById(id);
    return this.repo.deleteRecipe(id);
  }

  async addIngredientToRecipe(recipeId, data) {
    return this.repo.createRecipeDetail({
      RecipeID: recipeId,
      ItemID: data.ItemID,
      Qty: data.Qty,
      Unit: data.Unit,
    });
  }

  async removeIngredientFromRecipe(recipeId, detailId) {
    return this.repo.deleteRecipeDetail(detailId);
  }
}

module.exports = InventoryService;
