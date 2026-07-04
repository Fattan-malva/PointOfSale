const db = require('../../db');
const uuidv7 = require('../../helpers/uuidv7');

class PromotionRepository {
  async findAll(filters = {}) {
    let query = db('Promotion').orderBy('Priority', 'desc');
    if (filters.IsActive !== undefined) query = query.where('IsActive', filters.IsActive);
    if (filters.PromotionType) query = query.where('PromotionType', filters.PromotionType);
    if (filters.limit) query = query.limit(filters.limit);
    if (filters.offset) query = query.offset(filters.offset);
    return query;
  }

  async countAll(filters = {}) {
    let query = db('Promotion');
    if (filters.IsActive !== undefined) query = query.where('IsActive', filters.IsActive);
    if (filters.PromotionType) query = query.where('PromotionType', filters.PromotionType);
    return query.count('PromotionID as total').first();
  }

  async findById(id) {
    return db('Promotion').where('PromotionID', id).first();
  }

  async findActivePromotions() {
    const now = new Date();
    return db('Promotion')
      .where('IsActive', true)
      .where('StartDate', '<=', now)
      .where(function() {
        this.where('EndDate', '>=', now).orWhereNull('EndDate');
      })
      .orderBy('Priority', 'desc');
  }

  async create(data) {
    data.PromotionID = uuidv7();
    await db('Promotion').insert(data);
    return this.findById(data.PromotionID);
  }

  async update(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Promotion').where('PromotionID', id).update(data);
    return this.findById(id);
  }

  async delete(id) {
    return db('Promotion').where('PromotionID', id).del();
  }

  async findItemsByPromotionId(promotionId) {
    return db('PromotionItem as pi')
      .join('Item', 'pi.ItemID', 'Item.ItemID')
      .where('pi.PromotionID', promotionId)
      .select('pi.*', 'Item.ItemName', 'Item.ItemCode', 'Item.Price')
      .orderBy('pi.CreatedAt');
  }

  async addItem(promotionId, itemId) {
    await db('PromotionItem').insert({
      PromotionItemID: uuidv7(),
      PromotionID: promotionId,
      ItemID: itemId,
    });
    return db('PromotionItem')
      .join('Item', 'PromotionItem.ItemID', 'Item.ItemID')
      .where({ 'PromotionItem.PromotionID': promotionId, 'PromotionItem.ItemID': itemId })
      .select('PromotionItem.*', 'Item.ItemName', 'Item.ItemCode', 'Item.Price')
      .first();
  }

  async removeItem(promotionId, itemId) {
    return db('PromotionItem').where({ PromotionID: promotionId, ItemID: itemId }).del();
  }
}

module.exports = PromotionRepository;
