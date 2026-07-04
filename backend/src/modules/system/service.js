const SystemRepository = require('./repository');

class SystemService {
  constructor() {
    this.repo = new SystemRepository();
  }

  async getAuditLogs(filters = {}) {
    return this.repo.findAuditLogs(filters);
  }

  async countAuditLogs(filters = {}) {
    return this.repo.countAuditLogs(filters);
  }

  async getUserActivities(filters = {}) {
    return this.repo.findUserActivities(filters);
  }

  async countUserActivities(filters = {}) {
    return this.repo.countUserActivities(filters);
  }
}

module.exports = SystemService;
