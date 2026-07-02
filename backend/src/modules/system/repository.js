const db = require('../../db');
const uuidv7 = require('../../helpers/uuidv7');

class SystemRepository {
  async createAuditLog(data) {
    data.AuditID = uuidv7();
    return db('AuditLog').insert(data);
  }

  async findAuditLogs(filters = {}) {
    let query = db('AuditLog').orderBy('CreatedAt', 'desc');
    if (filters.Module) query = query.where('Module', filters.Module);
    if (filters.Action) query = query.where('Action', filters.Action);
    if (filters.UserID) query = query.where('UserID', filters.UserID);
    if (filters.TableName) query = query.where('TableName', filters.TableName);
    if (filters.RecordID) query = query.where('RecordID', filters.RecordID);
    if (filters.DateFrom) query = query.where('CreatedAt', '>=', new Date(filters.DateFrom));
    if (filters.DateTo) query = query.where('CreatedAt', '<=', new Date(filters.DateTo));
    return query;
  }

  async createUserActivity(data) {
    data.ActivityID = uuidv7();
    return db('UserActivity').insert(data);
  }

  async findUserActivities(filters = {}) {
    let query = db('UserActivity').orderBy('CreatedAt', 'desc');
    if (filters.UserID) query = query.where('UserID', filters.UserID);
    if (filters.Action) query = query.where('Action', filters.Action);
    if (filters.UserType) query = query.where('UserType', filters.UserType);
    if (filters.DateFrom) query = query.where('CreatedAt', '>=', new Date(filters.DateFrom));
    if (filters.DateTo) query = query.where('CreatedAt', '<=', new Date(filters.DateTo));
    return query;
  }
}

module.exports = SystemRepository;
