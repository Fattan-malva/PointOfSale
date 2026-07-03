const db = require('../db');
const uuidv7 = require('./uuidv7');

async function auditLog({ UserID, Module, Action, TableName, RecordID, OldValue, NewValue, IPAddress }) {
  await db('AuditLog').insert({
    AuditID: uuidv7(),
    UserID: UserID || null,
    Module,
    Action,
    TableName,
    RecordID,
    OldValue: OldValue ? JSON.stringify(OldValue) : null,
    NewValue: NewValue ? JSON.stringify(NewValue) : null,
    IPAddress: IPAddress || null,
    CreatedAt: new Date(),
  });
}

async function userActivity({ UserID, UserType, Action, Device, IPAddress, UserAgent }) {
  // Truncate Device to column length (100 chars) to avoid SQL truncation error
  const safeDevice = Device && Device.length > 100 ? Device.substring(0, 100) : Device;
  await db('UserActivity').insert({
    ActivityID: uuidv7(),
    UserID,
    UserType: UserType || 'Employee',
    Action,
    Device: safeDevice || null,
    IPAddress: IPAddress || null,
    UserAgent: UserAgent || null,
    CreatedAt: new Date(),
  });
}

module.exports = { auditLog, userActivity };
