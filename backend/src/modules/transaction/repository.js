const db = require('../../db');
const uuidv7 = require('../../helpers/uuidv7');

class TransactionRepository {
  async findOrderById(id) {
    return db('Order')
      .leftJoin('Branch', 'Order.BranchID', 'Branch.BranchID')
      .leftJoin('MstCustomer', 'Order.CustomerID', 'MstCustomer.CustomerID')
      .leftJoin('Table', 'Order.TableID', 'Table.TableID')
      .leftJoin('MstUser', 'Order.UserID', 'MstUser.UserID')
      .where('Order.OrderID', id)
      .select(
        'Order.*',
        'Branch.BranchName',
        'MstCustomer.FullName as CustomerName',
        'Table.TableCode',
        'Table.TableName',
        'MstUser.FullName as UserName'
      )
      .first();
  }

  async findOrders(filters = {}) {
    let query = db('Order')
      .leftJoin('Branch', 'Order.BranchID', 'Branch.BranchID')
      .leftJoin('MstCustomer', 'Order.CustomerID', 'MstCustomer.CustomerID')
      .leftJoin('Table', 'Order.TableID', 'Table.TableID')
      .leftJoin('MstUser', 'Order.UserID', 'MstUser.UserID')
      .select(
        'Order.*',
        'Branch.BranchName',
        'MstCustomer.FullName as CustomerName',
        'Table.TableCode',
        'MstUser.FullName as UserName'
      );

    if (filters.BranchID) query = query.where('Order.BranchID', filters.BranchID);
    if (filters.Status) query = query.where('Order.Status', filters.Status);
    if (filters.PaymentStatus) query = query.where('Order.PaymentStatus', filters.PaymentStatus);
    if (filters.OrderType) query = query.where('Order.OrderType', filters.OrderType);
    if (filters.DateFrom) query = query.where('Order.CreatedAt', '>=', filters.DateFrom);
    if (filters.DateTo) query = query.where('Order.CreatedAt', '<=', filters.DateTo);

    return query.orderBy('Order.CreatedAt', 'desc');
  }

  async createOrder(data) {
    data.OrderID = uuidv7();
    await db('Order').insert(data);
    return this.findOrderById(data.OrderID);
  }

  async updateOrder(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('Order').where('OrderID', id).update(data);
    return this.findOrderById(id);
  }

  async findOrderDetails(orderId) {
    return db('OrderDetail')
      .leftJoin('Item', 'OrderDetail.ItemID', 'Item.ItemID')
      .where('OrderDetail.OrderID', orderId)
      .select('OrderDetail.*', 'Item.ItemCode', 'Item.ItemType')
      .orderBy('OrderDetail.CreatedAt');
  }

  async findOrderDetailById(id) {
    return db('OrderDetail').where('OrderDetailID', id).first();
  }

  async createOrderDetail(data) {
    data.OrderDetailID = uuidv7();
    await db('OrderDetail').insert(data);
    return db('OrderDetail').where('OrderDetailID', data.OrderDetailID).first();
  }

  async updateOrderDetail(id, data) {
    await db('OrderDetail').where('OrderDetailID', id).update(data);
    return db('OrderDetail').where('OrderDetailID', id).first();
  }

  async deleteOrderDetail(id) {
    return db('OrderDetail').where('OrderDetailID', id).del();
  }

  async findOrderModifiers(orderDetailId) {
    return db('OrderModifier').where('OrderDetailID', orderDetailId).orderBy('CreatedAt');
  }

  async createOrderModifier(data) {
    data.OrderModifierID = uuidv7();
    await db('OrderModifier').insert(data);
    return db('OrderModifier').where('OrderModifierID', data.OrderModifierID).first();
  }

  async deleteOrderModifier(id) {
    return db('OrderModifier').where('OrderModifierID', id).del();
  }

  async findOrderDiscounts(orderId) {
    return db('OrderDiscount').where('OrderID', orderId).orderBy('CreatedAt');
  }

  async createOrderDiscount(data) {
    data.OrderDiscountID = uuidv7();
    await db('OrderDiscount').insert(data);
    return db('OrderDiscount').where('OrderDiscountID', data.OrderDiscountID).first();
  }

  async deleteOrderDiscount(id) {
    return db('OrderDiscount').where('OrderDiscountID', id).del();
  }

  async findPaymentsByOrderId(orderId) {
    return db('Payment')
      .join('PaymentMethod', 'Payment.PaymentMethodID', 'PaymentMethod.PaymentMethodID')
      .where('Payment.OrderID', orderId)
      .select('Payment.*', 'PaymentMethod.MethodName')
      .orderBy('Payment.CreatedAt');
  }

  async createPayment(data) {
    data.PaymentID = uuidv7();
    await db('Payment').insert(data);
    return db('Payment').where('PaymentID', data.PaymentID).first();
  }

  async findKitchenByOrderId(orderId) {
    return db('Kitchen').where('OrderID', orderId).orderBy('CreatedAt');
  }

  async findKitchenPending() {
    return db('Kitchen')
      .join('Order', 'Kitchen.OrderID', 'Order.OrderID')
      .select('Kitchen.*', 'Order.OrderNumber', 'Order.TableID')
      .whereIn('Kitchen.Status', ['Pending', 'Preparing'])
      .orderBy('Kitchen.CreatedAt');
  }

  async createKitchenItem(data) {
    data.KitchenID = uuidv7();
    await db('Kitchen').insert(data);
    return db('Kitchen').where('KitchenID', data.KitchenID).first();
  }

  async updateKitchenStatus(id, status) {
    await db('Kitchen').where('KitchenID', id).update({ Status: status, UpdatedAt: db.fn.now() });
    return db('Kitchen').where('KitchenID', id).first();
  }

  async findTableHistoryByOrderId(orderId) {
    return db('TableHistory').where('OrderID', orderId).first();
  }

  async createTableHistory(data) {
    data.TableHistoryID = uuidv7();
    await db('TableHistory').insert(data);
    return db('TableHistory').where('TableHistoryID', data.TableHistoryID).first();
  }

  async closeTableHistory(orderId) {
    await db('TableHistory').where('OrderID', orderId).update({ EndTime: db.fn.now() });
  }

  async createVoucherHistory(data) {
    data.VoucherHistoryID = uuidv7();
    await db('VoucherHistory').insert(data);
  }

  async createPointHistory(data) {
    data.PointHistoryID = uuidv7();
    await db('PointHistory').insert(data);
  }

  async updateVoucherUsage(voucherId) {
    return db('Voucher').where('VoucherID', voucherId).increment('CurrentUses', 1);
  }

  async findAllShiftClosing(filters = {}) {
    let query = db('ShiftClosing')
      .join('Branch', 'ShiftClosing.BranchID', 'Branch.BranchID')
      .join('MstUser', 'ShiftClosing.UserID', 'MstUser.UserID')
      .join('Shift', 'ShiftClosing.ShiftID', 'Shift.ShiftID')
      .select('ShiftClosing.*', 'Branch.BranchName', 'MstUser.FullName as UserName', 'Shift.ShiftName');

    if (filters.BranchID) query = query.where('ShiftClosing.BranchID', filters.BranchID);
    return query.orderBy('ShiftClosing.CreatedAt', 'desc');
  }

  async findShiftClosingById(id) {
    return db('ShiftClosing')
      .join('Branch', 'ShiftClosing.BranchID', 'Branch.BranchID')
      .join('MstUser', 'ShiftClosing.UserID', 'MstUser.UserID')
      .join('Shift', 'ShiftClosing.ShiftID', 'Shift.ShiftID')
      .where('ShiftClosing.ShiftClosingID', id)
      .select('ShiftClosing.*', 'Branch.BranchName', 'MstUser.FullName as UserName', 'Shift.ShiftName')
      .first();
  }

  async createShiftClosing(data) {
    data.ShiftClosingID = uuidv7();
    await db('ShiftClosing').insert(data);
    return this.findShiftClosingById(data.ShiftClosingID);
  }

  async updateShiftClosing(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('ShiftClosing').where('ShiftClosingID', id).update(data);
    return this.findShiftClosingById(id);
  }

  async getDailySalesSummary(date, branchId) {
    let query = db('Order')
      .where('Status', 'Completed')
      .where(db.raw('CAST(CreatedAt AS DATE)'), date);

    if (branchId) query = query.where('BranchID', branchId);

    return query
      .select(
        db.raw('COUNT(*) as TotalOrders'),
        db.raw('COALESCE(SUM(SubTotal), 0) as TotalSubTotal'),
        db.raw('COALESCE(SUM(DiscountTotal), 0) as TotalDiscount'),
        db.raw('COALESCE(SUM(TaxTotal), 0) as TotalTax'),
        db.raw('COALESCE(SUM(GrandTotal), 0) as TotalGrandTotal')
      )
      .first();
  }
}

module.exports = TransactionRepository;
