const ReportingRepository = require('./repository');

class ReportingService {
  constructor() {
    this.repo = new ReportingRepository();
  }

  async getSalesReport(filters) {
    return this.repo.getSalesReport(filters);
  }

  async getSalesByPaymentMethod(filters) {
    return this.repo.getSalesByPaymentMethod(filters);
  }

  async getSalesByCashier(filters) {
    return this.repo.getSalesByCashier(filters);
  }

  async getTopSellingItems(filters) {
    return this.repo.getTopSellingItems(filters);
  }

  async getStockReport(filters) {
    return this.repo.getStockReport(filters);
  }

  async getShiftReport(filters) {
    return this.repo.getShiftReport(filters);
  }

  async getDashboardSummary(filters) {
    return this.repo.getDashboardSummary(filters);
  }
}

module.exports = ReportingService;
