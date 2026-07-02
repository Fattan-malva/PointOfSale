const SystemRepository = require('./repository');

class SystemService {
  constructor() {
    this.repo = new SystemRepository();
  }

  async getAuditLogs(filters) {
    return this.repo.findAuditLogs(filters);
  }

  async getUserActivities(filters) {
    return this.repo.findUserActivities(filters);
  }
}

module.exports = SystemService;
