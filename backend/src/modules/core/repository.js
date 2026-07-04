const db = require('../../db');
const uuidv7 = require('../../helpers/uuidv7');

class CoreRepository {
  // Branch
  async findAllBranch({ limit, offset } = {}) {
    let query = db('Branch').select('*').orderBy('BranchName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllBranch() {
    return db('Branch').count('BranchID as total').first();
  }

  async findBranchById(id) {
    return db('Branch').where('BranchID', id).first();
  }

  async createBranch(data) {
    data.BranchID = uuidv7();
    await db('Branch').insert(data);
    return this.findBranchById(data.BranchID);
  }

  async updateBranch(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Branch').where('BranchID', id).update(data);
    return this.findBranchById(id);
  }

  async deleteBranch(id) {
    return db('Branch').where('BranchID', id).del();
  }

  // MstRole
  async findAllRole({ limit, offset } = {}) {
    let query = db('MstRole').select('*').orderBy('RoleName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllRole() {
    return db('MstRole').count('RoleID as total').first();
  }

  async findRoleById(id) {
    return db('MstRole').where('RoleID', id).first();
  }

  async createRole(data) {
    data.RoleID = uuidv7();
    await db('MstRole').insert(data);
    return db('MstRole').where('RoleID', data.RoleID).first();
  }

  async updateRole(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('MstRole').where('RoleID', id).update(data);
    return db('MstRole').where('RoleID', id).first();
  }

  async deleteRole(id) {
    return db('MstRole').where('RoleID', id).del();
  }

  // MstPermission
  async findAllPermission({ limit, offset } = {}) {
    let query = db('MstPermission').select('*').orderBy('PermissionName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllPermission() {
    return db('MstPermission').count('PermissionID as total').first();
  }

  async findPermissionById(id) {
    return db('MstPermission').where('PermissionID', id).first();
  }

  async createPermission(data) {
    data.PermissionID = uuidv7();
    await db('MstPermission').insert(data);
    return db('MstPermission').where('PermissionID', data.PermissionID).first();
  }

  async deletePermission(id) {
    return db('MstPermission').where('PermissionID', id).del();
  }

  // RolePermission
  async findPermissionsByRoleId(roleId) {
    return db('RolePermission as rp')
      .join('MstPermission as mp', 'rp.PermissionID', 'mp.PermissionID')
      .where('rp.RoleID', roleId)
      .select('mp.*');
  }

  async assignPermission(roleId, permissionId) {
    return db('RolePermission').insert({
      RolePermissionID: uuidv7(),
      RoleID: roleId,
      PermissionID: permissionId,
    });
  }

  async removePermission(roleId, permissionId) {
    return db('RolePermission').where({ RoleID: roleId, PermissionID: permissionId }).del();
  }

  // MstUser
  async findAllUser({ limit, offset } = {}) {
    let query = db('MstUser')
      .join('Branch', 'MstUser.BranchID', 'Branch.BranchID')
      .join('MstRole', 'MstUser.RoleID', 'MstRole.RoleID')
      .select('MstUser.*', 'Branch.BranchName', 'MstRole.RoleName')
      .orderBy('MstUser.FullName');
    if (limit) query = query.limit(limit);
    if (offset) query = query.offset(offset);
    return query;
  }

  async countAllUser() {
    return db('MstUser').count('UserID as total').first();
  }

  async findUserById(id) {
    return db('MstUser')
      .join('Branch', 'MstUser.BranchID', 'Branch.BranchID')
      .join('MstRole', 'MstUser.RoleID', 'MstRole.RoleID')
      .where('MstUser.UserID', id)
      .select('MstUser.*', 'Branch.BranchName', 'MstRole.RoleName')
      .first();
  }

  async findUserByUsername(username) {
    return db('MstUser')
      .join('Branch', 'MstUser.BranchID', 'Branch.BranchID')
      .join('MstRole', 'MstUser.RoleID', 'MstRole.RoleID')
      .where('MstUser.Username', username)
      .select('MstUser.*', 'Branch.BranchName', 'MstRole.RoleName')
      .first();
  }

  async createUser(data) {
    data.UserID = uuidv7();
    await db('MstUser').insert(data);
    return this.findUserById(data.UserID);
  }

  async updateUser(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('MstUser').where('UserID', id).update(data);
    return this.findUserById(id);
  }

  async deleteUser(id) {
    return db('MstUser').where('UserID', id).del();
  }

  // AppConfig
  async findAppConfig() {
    return db('AppConfig').first();
  }

  async updateAppConfig(data) {
    data.UpdatedAt = db.fn.now();
    await db('AppConfig').update(data);
    return this.findAppConfig();
  }
}

module.exports = CoreRepository;
