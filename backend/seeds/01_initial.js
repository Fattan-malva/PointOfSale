const crypto = require('crypto');

function uuidv7() {
  const ts = Date.now().toString(16).padStart(12, '0');
  const rand = crypto.randomBytes(9).toString('hex');
  const variant = (8 + Math.floor(Math.random() * 4)).toString(16);
  const hex = ts + '7' + rand.slice(0, 3) + variant + rand.slice(3);
  return hex.slice(0, 8) + '-' + hex.slice(8, 12) + '-' + hex.slice(12, 16) + '-' + hex.slice(16, 20) + '-' + hex.slice(20);
}

const BRANCH_ID = '00000000-0000-0000-0000-000000000001';
const USER_IDS = {
  ADMIN: '00000000-0000-0000-0000-000000000001',
  OWNER: '00000000-0000-0000-0000-000000000002',
  MANAGER: '00000000-0000-0000-0000-000000000003',
  CASHIER: '00000000-0000-0000-0000-000000000004',
  KITCHEN: '00000000-0000-0000-0000-000000000005',
};

exports.seed = async (knex) => {
  const existing = await knex('MstRole').first();
  if (existing) {
    console.log('01_initial: Core data already exists, skipping');
    return;
  }

  const ROLE = {
    ADMIN: uuidv7(),
    OWNER: uuidv7(),
    MANAGER: uuidv7(),
    CASHIER: uuidv7(),
    KITCHEN: uuidv7(),
    CUSTOMER: uuidv7(),
  };

  const PERM = {
    CREATE_ORDER: uuidv7(), CANCEL_ORDER: uuidv7(), EDIT_PRICE: uuidv7(),
    REFUND: uuidv7(), VIEW_SALES: uuidv7(), MANAGE_INVENTORY: uuidv7(),
    MANAGE_EMPLOYEE: uuidv7(), MANAGE_PROMOTION: uuidv7(), VIEW_AUDIT_LOG: uuidv7(),
    VIEW_ACTIVITY_LOG: uuidv7(), MANAGE_BRANCH: uuidv7(), MANAGE_ROLE_PERM: uuidv7(),
    MANAGE_APP_CONFIG: uuidv7(), MANAGE_CUSTOMER: uuidv7(), MANAGE_MEDIA: uuidv7(),
    MANAGE_CATEGORY: uuidv7(), MANAGE_ITEM: uuidv7(), MANAGE_MODIFIER: uuidv7(),
    MANAGE_PACKAGE: uuidv7(), MANAGE_TABLE: uuidv7(), VIEW_TABLE: uuidv7(),
    MANAGE_TAX: uuidv7(), MANAGE_DISCOUNT: uuidv7(), MANAGE_VOUCHER: uuidv7(),
    MANAGE_PAYMENT_METHOD: uuidv7(), MANAGE_SHIFT: uuidv7(), VIEW_ORDER: uuidv7(),
    MANAGE_PAYMENT: uuidv7(), MANAGE_SUPPLIER: uuidv7(), MANAGE_PURCHASE: uuidv7(),
    MANAGE_STOCK: uuidv7(), MANAGE_RECIPE: uuidv7(),
  };

  const ALL_PERMS = Object.values(PERM);

  await knex.transaction(async (trx) => {
    await trx('MstRole').insert([
      { RoleID: ROLE.ADMIN, RoleName: 'Admin', IsActive: true },
      { RoleID: ROLE.OWNER, RoleName: 'Owner', IsActive: true },
      { RoleID: ROLE.MANAGER, RoleName: 'Manager', IsActive: true },
      { RoleID: ROLE.CASHIER, RoleName: 'Cashier', IsActive: true },
      { RoleID: ROLE.KITCHEN, RoleName: 'Kitchen', IsActive: true },
      { RoleID: ROLE.CUSTOMER, RoleName: 'Customer', IsActive: true },
    ]);

    await trx('MstPermission').insert([
      { PermissionID: PERM.CREATE_ORDER, PermissionName: 'CanCreateOrder' },
      { PermissionID: PERM.CANCEL_ORDER, PermissionName: 'CanCancelOrder' },
      { PermissionID: PERM.EDIT_PRICE, PermissionName: 'CanEditPrice' },
      { PermissionID: PERM.REFUND, PermissionName: 'CanRefund' },
      { PermissionID: PERM.VIEW_SALES, PermissionName: 'CanViewSales' },
      { PermissionID: PERM.MANAGE_INVENTORY, PermissionName: 'CanManageInventory' },
      { PermissionID: PERM.MANAGE_EMPLOYEE, PermissionName: 'CanManageEmployee' },
      { PermissionID: PERM.MANAGE_PROMOTION, PermissionName: 'CanManagePromotion' },
      { PermissionID: PERM.VIEW_AUDIT_LOG, PermissionName: 'CanViewAuditLog' },
      { PermissionID: PERM.VIEW_ACTIVITY_LOG, PermissionName: 'CanViewActivityLog' },
      { PermissionID: PERM.MANAGE_BRANCH, PermissionName: 'CanManageBranch' },
      { PermissionID: PERM.MANAGE_ROLE_PERM, PermissionName: 'CanManageRolePermission' },
      { PermissionID: PERM.MANAGE_APP_CONFIG, PermissionName: 'CanManageAppConfig' },
      { PermissionID: PERM.MANAGE_CUSTOMER, PermissionName: 'CanManageCustomer' },
      { PermissionID: PERM.MANAGE_MEDIA, PermissionName: 'CanManageMedia' },
      { PermissionID: PERM.MANAGE_CATEGORY, PermissionName: 'CanManageCategory' },
      { PermissionID: PERM.MANAGE_ITEM, PermissionName: 'CanManageItem' },
      { PermissionID: PERM.MANAGE_MODIFIER, PermissionName: 'CanManageModifier' },
      { PermissionID: PERM.MANAGE_PACKAGE, PermissionName: 'CanManagePackage' },
      { PermissionID: PERM.MANAGE_TABLE, PermissionName: 'CanManageTable' },
      { PermissionID: PERM.VIEW_TABLE, PermissionName: 'CanViewTable' },
      { PermissionID: PERM.MANAGE_TAX, PermissionName: 'CanManageTax' },
      { PermissionID: PERM.MANAGE_DISCOUNT, PermissionName: 'CanManageDiscount' },
      { PermissionID: PERM.MANAGE_VOUCHER, PermissionName: 'CanManageVoucher' },
      { PermissionID: PERM.MANAGE_PAYMENT_METHOD, PermissionName: 'CanManagePaymentMethod' },
      { PermissionID: PERM.MANAGE_SHIFT, PermissionName: 'CanManageShift' },
      { PermissionID: PERM.VIEW_ORDER, PermissionName: 'CanViewOrder' },
      { PermissionID: PERM.MANAGE_PAYMENT, PermissionName: 'CanManagePayment' },
      { PermissionID: PERM.MANAGE_SUPPLIER, PermissionName: 'CanManageSupplier' },
      { PermissionID: PERM.MANAGE_PURCHASE, PermissionName: 'CanManagePurchase' },
      { PermissionID: PERM.MANAGE_STOCK, PermissionName: 'CanManageStock' },
      { PermissionID: PERM.MANAGE_RECIPE, PermissionName: 'CanManageRecipe' },
    ]);

    const rolePerms = [];
    const addRolePerms = (roleId, permKeys) => {
      for (const key of permKeys) {
        rolePerms.push({ RolePermissionID: uuidv7(), RoleID: roleId, PermissionID: PERM[key] });
      }
    };

    addRolePerms(ROLE.ADMIN, Object.keys(PERM));
    addRolePerms(ROLE.OWNER, Object.keys(PERM));
    addRolePerms(ROLE.MANAGER, [
      'CREATE_ORDER', 'CANCEL_ORDER', 'EDIT_PRICE', 'REFUND', 'VIEW_SALES',
      'MANAGE_INVENTORY', 'MANAGE_EMPLOYEE', 'MANAGE_PROMOTION',
      'MANAGE_CUSTOMER', 'MANAGE_CATEGORY', 'MANAGE_ITEM', 'MANAGE_MODIFIER',
      'MANAGE_PACKAGE', 'MANAGE_TABLE', 'VIEW_TABLE', 'MANAGE_TAX',
      'MANAGE_DISCOUNT', 'MANAGE_VOUCHER', 'MANAGE_SHIFT', 'VIEW_ORDER',
      'MANAGE_PAYMENT', 'MANAGE_SUPPLIER', 'MANAGE_PURCHASE', 'MANAGE_STOCK',
      'MANAGE_RECIPE',
    ]);
    addRolePerms(ROLE.CASHIER, ['CREATE_ORDER', 'CANCEL_ORDER', 'VIEW_ORDER', 'VIEW_TABLE', 'MANAGE_PAYMENT']);
    addRolePerms(ROLE.KITCHEN, ['CREATE_ORDER', 'VIEW_ORDER', 'VIEW_TABLE']);
    addRolePerms(ROLE.CUSTOMER, ['CREATE_ORDER']);

    await trx('RolePermission').insert(rolePerms);

    await trx('Branch').insert({
      BranchID: BRANCH_ID,
      BranchCode: 'MAIN',
      BranchName: 'Cabang Utama',
      Address: 'Jl. Merdeka No. 1, Jakarta',
      Phone: '021-12345678',
      Email: 'cabangutama@pos.com',
      IsActive: true,
    });

    const pwd = await require('bcrypt').hash('admin123', 10);

    await trx('MstUser').insert([
      { UserID: USER_IDS.ADMIN, RoleID: ROLE.ADMIN, BranchID: BRANCH_ID, Username: 'admin', PasswordHash: pwd, FullName: 'Super Admin', Email: 'admin@pos.com', Phone: '0812-0000001', IsActive: true },
      { UserID: USER_IDS.OWNER, RoleID: ROLE.OWNER, BranchID: BRANCH_ID, Username: 'owner', PasswordHash: pwd, FullName: 'Owner Utama', Email: 'owner@pos.com', Phone: '0812-0000002', IsActive: true },
      { UserID: USER_IDS.MANAGER, RoleID: ROLE.MANAGER, BranchID: BRANCH_ID, Username: 'manager', PasswordHash: pwd, FullName: 'Manager Cabang', Email: 'manager@pos.com', Phone: '0812-0000003', IsActive: true },
      { UserID: USER_IDS.CASHIER, RoleID: ROLE.CASHIER, BranchID: BRANCH_ID, Username: 'kasir', PasswordHash: pwd, FullName: 'Kasir 1', Email: 'kasir@pos.com', Phone: '0812-0000004', IsActive: true },
      { UserID: USER_IDS.KITCHEN, RoleID: ROLE.KITCHEN, BranchID: BRANCH_ID, Username: 'dapur', PasswordHash: pwd, FullName: 'Staff Dapur', Email: 'dapur@pos.com', Phone: '0812-0000005', IsActive: true },
    ]);

    const customerPwd = await require('bcrypt').hash('customer123', 10);
    await trx('MstCustomer').insert([
      { CustomerID: uuidv7(), CustomerCode: 'CUST-001', FullName: 'Budi Santoso', Phone: '0813-1111111', PasswordHash: customerPwd, Point: 1500, IsActive: true },
      { CustomerID: uuidv7(), CustomerCode: 'CUST-002', FullName: 'Siti Rahayu', Phone: '0813-2222222', PasswordHash: customerPwd, Point: 750, IsActive: true },
      { CustomerID: uuidv7(), CustomerCode: 'CUST-003', FullName: 'Ahmad Rizki', Phone: '0813-3333333', PasswordHash: customerPwd, Point: 2500, IsActive: true },
    ]);

    await trx('AppConfig').insert({
      ConfigID: uuidv7(),
      EnableKitchen: true, EnableInventory: true, EnableCustomerApp: true,
      EnableQROrdering: true, EnableVoucher: true, EnableDiscount: true,
      EnableTax: true, EnableServiceCharge: false, EnableSplitBill: false,
      EnableReservation: false, EnableDelivery: false, EnableLoyalty: true,
      EnableMembership: true, EnableMultiBranch: true, EnablePrinterBluetooth: true,
      EnableKitchenPrinter: true, EnableCashDrawer: true,
      Currency: 'IDR', DecimalDigit: 2,
    });

    console.log('01_initial: Core data seeded successfully');
    console.log('  Roles: 6, Permissions: 32, Users: 5, Customers: 3');
  });
};
