const crypto = require('crypto');

function uuidv7() {
  const ts = Date.now().toString(16).padStart(12, '0');
  const rand = crypto.randomBytes(9).toString('hex');
  const variant = (8 + Math.floor(Math.random() * 4)).toString(16);
  const hex = ts + '7' + rand.slice(0, 3) + variant + rand.slice(3);
  return hex.slice(0,8) + '-' + hex.slice(8,12) + '-' + hex.slice(12,16) + '-' + hex.slice(16,20) + '-' + hex.slice(20);
}

const R_ADMIN = uuidv7();
const R_OWNER = uuidv7();
const R_MANAGER = uuidv7();
const R_CASHIER = uuidv7();
const R_KITCHEN = uuidv7();
const R_CUSTOMER = uuidv7();

const P_CREATE_ORDER = uuidv7();
const P_CANCEL_ORDER = uuidv7();
const P_EDIT_PRICE = uuidv7();
const P_REFUND = uuidv7();
const P_VIEW_SALES = uuidv7();
const P_MANAGE_INVENTORY = uuidv7();
const P_MANAGE_EMPLOYEE = uuidv7();
const P_MANAGE_PROMOTION = uuidv7();
const P_VIEW_AUDIT_LOG = uuidv7();
const P_VIEW_ACTIVITY_LOG = uuidv7();
const P_MANAGE_BRANCH = uuidv7();
const P_MANAGE_ROLE_PERM = uuidv7();
const P_MANAGE_APP_CONFIG = uuidv7();
const P_MANAGE_CUSTOMER = uuidv7();
const P_MANAGE_MEDIA = uuidv7();
const P_MANAGE_CATEGORY = uuidv7();
const P_MANAGE_ITEM = uuidv7();
const P_MANAGE_MODIFIER = uuidv7();
const P_MANAGE_PACKAGE = uuidv7();
const P_MANAGE_TABLE = uuidv7();
const P_MANAGE_TAX = uuidv7();
const P_MANAGE_DISCOUNT = uuidv7();
const P_MANAGE_VOUCHER = uuidv7();
const P_MANAGE_PAYMENT_METHOD = uuidv7();
const P_MANAGE_SHIFT = uuidv7();
const P_VIEW_ORDER = uuidv7();
const P_MANAGE_PAYMENT = uuidv7();
const P_MANAGE_SUPPLIER = uuidv7();
const P_MANAGE_PURCHASE = uuidv7();
const P_MANAGE_STOCK = uuidv7();
const P_MANAGE_RECIPE = uuidv7();

exports.seed = async (knex) => {
  await knex.transaction(async (trx) => {
    await trx('RolePermission').del();
    await trx('MstPermission').del();
    await trx('MstRole').del();
    await trx('AppConfig').del();

    await trx('MstRole').insert([
      { RoleID: R_ADMIN, RoleName: 'Admin' },
      { RoleID: R_OWNER, RoleName: 'Owner' },
      { RoleID: R_MANAGER, RoleName: 'Manager' },
      { RoleID: R_CASHIER, RoleName: 'Cashier' },
      { RoleID: R_KITCHEN, RoleName: 'Kitchen' },
      { RoleID: R_CUSTOMER, RoleName: 'Customer' },
    ]);

    await trx('MstPermission').insert([
      { PermissionID: P_CREATE_ORDER, PermissionName: 'CanCreateOrder' },
      { PermissionID: P_CANCEL_ORDER, PermissionName: 'CanCancelOrder' },
      { PermissionID: P_EDIT_PRICE, PermissionName: 'CanEditPrice' },
      { PermissionID: P_REFUND, PermissionName: 'CanRefund' },
      { PermissionID: P_VIEW_SALES, PermissionName: 'CanViewSales' },
      { PermissionID: P_MANAGE_INVENTORY, PermissionName: 'CanManageInventory' },
      { PermissionID: P_MANAGE_EMPLOYEE, PermissionName: 'CanManageEmployee' },
      { PermissionID: P_MANAGE_PROMOTION, PermissionName: 'CanManagePromotion' },
      { PermissionID: P_VIEW_AUDIT_LOG, PermissionName: 'CanViewAuditLog' },
      { PermissionID: P_VIEW_ACTIVITY_LOG, PermissionName: 'CanViewActivityLog' },
      { PermissionID: P_MANAGE_BRANCH, PermissionName: 'CanManageBranch' },
      { PermissionID: P_MANAGE_ROLE_PERM, PermissionName: 'CanManageRolePermission' },
      { PermissionID: P_MANAGE_APP_CONFIG, PermissionName: 'CanManageAppConfig' },
      { PermissionID: P_MANAGE_CUSTOMER, PermissionName: 'CanManageCustomer' },
      { PermissionID: P_MANAGE_MEDIA, PermissionName: 'CanManageMedia' },
      { PermissionID: P_MANAGE_CATEGORY, PermissionName: 'CanManageCategory' },
      { PermissionID: P_MANAGE_ITEM, PermissionName: 'CanManageItem' },
      { PermissionID: P_MANAGE_MODIFIER, PermissionName: 'CanManageModifier' },
      { PermissionID: P_MANAGE_PACKAGE, PermissionName: 'CanManagePackage' },
      { PermissionID: P_MANAGE_TABLE, PermissionName: 'CanManageTable' },
      { PermissionID: P_MANAGE_TAX, PermissionName: 'CanManageTax' },
      { PermissionID: P_MANAGE_DISCOUNT, PermissionName: 'CanManageDiscount' },
      { PermissionID: P_MANAGE_VOUCHER, PermissionName: 'CanManageVoucher' },
      { PermissionID: P_MANAGE_PAYMENT_METHOD, PermissionName: 'CanManagePaymentMethod' },
      { PermissionID: P_MANAGE_SHIFT, PermissionName: 'CanManageShift' },
      { PermissionID: P_VIEW_ORDER, PermissionName: 'CanViewOrder' },
      { PermissionID: P_MANAGE_PAYMENT, PermissionName: 'CanManagePayment' },
      { PermissionID: P_MANAGE_SUPPLIER, PermissionName: 'CanManageSupplier' },
      { PermissionID: P_MANAGE_PURCHASE, PermissionName: 'CanManagePurchase' },
      { PermissionID: P_MANAGE_STOCK, PermissionName: 'CanManageStock' },
      { PermissionID: P_MANAGE_RECIPE, PermissionName: 'CanManageRecipe' },
    ]);

    await trx('RolePermission').insert([
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_CREATE_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_CANCEL_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_EDIT_PRICE },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_REFUND },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_VIEW_SALES },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_INVENTORY },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_EMPLOYEE },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_PROMOTION },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_VIEW_AUDIT_LOG },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_VIEW_ACTIVITY_LOG },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_BRANCH },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_ROLE_PERM },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_APP_CONFIG },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_CUSTOMER },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_MEDIA },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_CATEGORY },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_ITEM },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_MODIFIER },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_PACKAGE },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_TABLE },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_TAX },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_DISCOUNT },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_VOUCHER },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_PAYMENT_METHOD },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_SHIFT },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_VIEW_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_PAYMENT },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_SUPPLIER },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_PURCHASE },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_STOCK },
      { RolePermissionID: uuidv7(), RoleID: R_ADMIN, PermissionID: P_MANAGE_RECIPE },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_CREATE_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_CANCEL_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_EDIT_PRICE },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_REFUND },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_VIEW_SALES },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_INVENTORY },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_EMPLOYEE },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_PROMOTION },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_VIEW_AUDIT_LOG },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_VIEW_ACTIVITY_LOG },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_BRANCH },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_ROLE_PERM },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_APP_CONFIG },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_CUSTOMER },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_MEDIA },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_CATEGORY },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_ITEM },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_MODIFIER },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_PACKAGE },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_TABLE },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_TAX },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_DISCOUNT },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_VOUCHER },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_PAYMENT_METHOD },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_SHIFT },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_VIEW_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_PAYMENT },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_SUPPLIER },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_PURCHASE },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_STOCK },
      { RolePermissionID: uuidv7(), RoleID: R_OWNER, PermissionID: P_MANAGE_RECIPE },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_CREATE_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_CANCEL_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_EDIT_PRICE },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_REFUND },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_VIEW_SALES },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_INVENTORY },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_EMPLOYEE },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_PROMOTION },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_VIEW_AUDIT_LOG },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_VIEW_ACTIVITY_LOG },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_CUSTOMER },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_CATEGORY },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_ITEM },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_MODIFIER },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_PACKAGE },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_TABLE },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_DISCOUNT },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_VOUCHER },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_SHIFT },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_VIEW_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_PAYMENT },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_SUPPLIER },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_PURCHASE },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_STOCK },
      { RolePermissionID: uuidv7(), RoleID: R_MANAGER, PermissionID: P_MANAGE_RECIPE },
      { RolePermissionID: uuidv7(), RoleID: R_CASHIER, PermissionID: P_CREATE_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_CASHIER, PermissionID: P_CANCEL_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_CASHIER, PermissionID: P_VIEW_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_CASHIER, PermissionID: P_MANAGE_PAYMENT },
      { RolePermissionID: uuidv7(), RoleID: R_KITCHEN, PermissionID: P_CREATE_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_KITCHEN, PermissionID: P_VIEW_ORDER },
      { RolePermissionID: uuidv7(), RoleID: R_CUSTOMER, PermissionID: P_CREATE_ORDER },
    ]);

    const pwd = await require('bcrypt').hash('admin123', 10);
    await trx('MstUser').insert({
      UserID: '00000000-0000-0000-0000-000000000001',
      RoleID: R_ADMIN,
      BranchID: '00000000-0000-0000-0000-000000000001',
      Username: 'admin',
      PasswordHash: pwd,
      FullName: 'Super Admin',
      IsActive: true,
    });

    await trx('AppConfig').insert({
      ConfigID: uuidv7(),
      EnableKitchen: true,
      EnableInventory: true,
      EnableCustomerApp: true,
      EnableQROrdering: true,
      EnableVoucher: true,
      EnableDiscount: true,
      EnableTax: true,
      EnableServiceCharge: false,
      EnableSplitBill: false,
      EnableReservation: false,
      EnableDelivery: false,
      EnableLoyalty: true,
      EnableMembership: true,
      EnableMultiBranch: true,
      EnablePrinterBluetooth: true,
      EnableKitchenPrinter: true,
      EnableCashDrawer: true,
      Currency: 'IDR',
      DecimalDigit: 2,
    });
  });
};
