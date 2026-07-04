const db = require('../db');
const uuidv7 = require('./uuidv7');

function safeStringify(value) {
  if (value === undefined) return undefined;
  try {
    // Handle circular references (e.g. Timeout objects)
    const seen = new WeakSet();
    return JSON.stringify(value, (key, val) => {
      if (typeof val === 'object' && val !== null) {
        if (seen.has(val)) return '[Circular]';
        seen.add(val);
      }
      if (typeof val === 'function') return `[Function ${val.name || 'anonymous'}]`;
      return val;
    });
  } catch (e) {
    // Last resort: avoid throwing and breaking the request
    try {
      return String(value);
    } catch (_) {
      return '[Unserializable]';
    }
  }
}

async function auditLog({ UserID, Module, Action, TableName, RecordID, OldValue, NewValue, IPAddress }) {
  await db('AuditLog').insert({
    AuditID: uuidv7(),
    UserID: UserID || null,
    Module,
    Action,
    TableName,
    RecordID,
    OldValue: OldValue ? safeStringify(OldValue) : null,
    NewValue: NewValue ? safeStringify(NewValue) : null,
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
