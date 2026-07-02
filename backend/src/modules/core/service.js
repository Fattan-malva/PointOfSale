const CoreRepository = require('./repository');
const bcrypt = require('bcrypt');
const { auditLog } = require('../../helpers/audit');

class CoreService {
  constructor() {
    this.repository = new CoreRepository();
  }

  // Branch
  async getAllBranch() {
    return this.repository.findAllBranch();
  }

  async getBranchById(id) {
    const branch = await this.repository.findBranchById(id);
    if (!branch) throw new Error('Branch not found');
    return branch;
  }

  async createBranch(data) {
    return this.repository.createBranch(data);
  }

  async updateBranch(id, data) {
    await this.getBranchById(id);
    return this.repository.updateBranch(id, data);
  }

  async deleteBranch(id) {
    await this.getBranchById(id);
    return this.repository.deleteBranch(id);
  }

  // Role
  async getAllRole() {
    return this.repository.findAllRole();
  }

  async getRoleById(id) {
    const role = await this.repository.findRoleById(id);
    if (!role) throw new Error('Role not found');
    return role;
  }

  async createRole(data) {
    return this.repository.createRole(data);
  }

  async updateRole(id, data) {
    await this.getRoleById(id);
    return this.repository.updateRole(id, data);
  }

  async deleteRole(id) {
    await this.getRoleById(id);
    return this.repository.deleteRole(id);
  }

  // Permission
  async getAllPermission() {
    return this.repository.findAllPermission();
  }

  async createPermission(data) {
    return this.repository.createPermission(data);
  }

  async deletePermission(id) {
    return this.repository.deletePermission(id);
  }

  // RolePermission
  async getPermissionsByRoleId(roleId) {
    await this.getRoleById(roleId);
    return this.repository.findPermissionsByRoleId(roleId);
  }

  async assignPermission(roleId, permissionId) {
    await this.getRoleById(roleId);
    return this.repository.assignPermission(roleId, permissionId);
  }

  async removePermission(roleId, permissionId) {
    await this.getRoleById(roleId);
    return this.repository.removePermission(roleId, permissionId);
  }

  // User
  async getAllUser() {
    return this.repository.findAllUser();
  }

  async getUserById(id) {
    const user = await this.repository.findUserById(id);
    if (!user) throw new Error('User not found');
    return user;
  }

  async createUser(data) {
    data.PasswordHash = await bcrypt.hash(data.PasswordHash, 10);
    const user = await this.repository.createUser(data);

    await auditLog({
      Module: 'Core',
      Action: 'CreateUser',
      TableName: 'MstUser',
      RecordID: user.UserID,
      NewValue: { Username: user.Username, FullName: user.FullName, RoleID: user.RoleID, BranchID: user.BranchID },
    });

    return user;
  }

  async updateUser(id, data) {
    const old = await this.getUserById(id);
    if (data.PasswordHash) {
      data.PasswordHash = await bcrypt.hash(data.PasswordHash, 10);
    }
    const updated = await this.repository.updateUser(id, data);

    await auditLog({
      Module: 'Core',
      Action: 'UpdateUser',
      TableName: 'MstUser',
      RecordID: id,
      OldValue: { Username: old.Username, FullName: old.FullName, IsActive: old.IsActive, RoleID: old.RoleID },
      NewValue: data,
    });

    return updated;
  }

  async deleteUser(id) {
    const old = await this.getUserById(id);
    await this.repository.deleteUser(id);

    await auditLog({
      Module: 'Core',
      Action: 'DeleteUser',
      TableName: 'MstUser',
      RecordID: id,
      OldValue: { Username: old.Username, FullName: old.FullName },
    });
  }

  async loginUser(username, password) {
    const user = await this.repository.findUserByUsername(username);
    if (!user) throw new Error('Invalid username or password');
    if (!user.IsActive) throw new Error('User is deactivated');

    const isValid = await bcrypt.compare(password, user.PasswordHash);
    if (!isValid) throw new Error('Invalid username or password');

    return user;
  }

  // AppConfig
  async getAppConfig() {
    return this.repository.findAppConfig();
  }

  async updateAppConfig(data) {
    return this.repository.updateAppConfig(data);
  }
}

module.exports = CoreService;
