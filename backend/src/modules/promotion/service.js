const PromotionRepository = require('./repository');

class PromotionService {
  constructor() {
    this.repo = new PromotionRepository();
  }

  async getAll(filters = {}) {
    return this.repo.findAll(filters);
  }

  async countAll(filters = {}) {
    return this.repo.countAll(filters);
  }

  async getById(id) {
    const p = await this.repo.findById(id);
    if (!p) throw new Error('Promotion not found');
    return p;
  }

  async create(data) {
    return this.repo.create(data);
  }

  async update(id, data) {
    await this.getById(id);
    return this.repo.update(id, data);
  }

  async delete(id) {
    await this.getById(id);
    return this.repo.delete(id);
  }

  async getItems(promotionId) {
    await this.getById(promotionId);
    return this.repo.findItemsByPromotionId(promotionId);
  }

  async addItem(promotionId, itemId) {
    await this.getById(promotionId);
    return this.repo.addItem(promotionId, itemId);
  }

  async removeItem(promotionId, itemId) {
    await this.getById(promotionId);
    return this.repo.removeItem(promotionId, itemId);
  }
}

module.exports = PromotionService;
