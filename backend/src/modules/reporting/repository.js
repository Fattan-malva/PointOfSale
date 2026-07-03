const db = require('../../db');

class ReportingRepository {
  async getSalesReport({ DateFrom, DateTo, BranchID }) {
    let query = db('Order')
      .leftJoin('Branch', 'Order.BranchID', 'Branch.BranchID')
      .leftJoin('MstUser', 'Order.UserID', 'MstUser.UserID')
      .whereIn('Order.Status', ['Completed', 'Confirmed'])
      .where('Order.CreatedAt', '>=', new Date(DateFrom || new Date().toISOString().split('T')[0]))
      .where('Order.CreatedAt', '<=', new Date(DateTo || new Date(Date.now() + 86400000).toISOString().split('T')[0]));

    if (BranchID) query = query.where('Order.BranchID', BranchID);

    return query
      .select(
        db.raw('CAST(Order.CreatedAt AS DATE) as Date'),
        'Branch.BranchName',
        db.raw('COUNT(DISTINCT Order.OrderID) as TotalOrders'),
        db.raw('COALESCE(SUM(Order.SubTotal), 0) as TotalSubTotal'),
        db.raw('COALESCE(SUM(Order.DiscountTotal), 0) as TotalDiscount'),
        db.raw('COALESCE(SUM(Order.TaxTotal), 0) as TotalTax'),
        db.raw('COALESCE(SUM(Order.GrandTotal), 0) as TotalGrandTotal'),
        db.raw('COALESCE(AVG(Order.GrandTotal), 0) as AverageOrderValue')
      )
      .groupBy(db.raw('CAST(Order.CreatedAt AS DATE)'), 'Branch.BranchName')
      .orderBy('Date', 'desc');
  }

  async getSalesByPaymentMethod({ DateFrom, DateTo, BranchID }) {
    let query = db('Payment')
      .join('Order', 'Payment.OrderID', 'Order.OrderID')
      .join('PaymentMethod', 'Payment.PaymentMethodID', 'PaymentMethod.PaymentMethodID')
      .whereIn('Order.Status', ['Completed', 'Confirmed']);

    if (BranchID) query = query.where('Order.BranchID', BranchID);
    if (DateFrom) query = query.where('Payment.CreatedAt', '>=', new Date(DateFrom));
    if (DateTo) query = query.where('Payment.CreatedAt', '<=', new Date(DateTo));

    return query
      .select(
        'PaymentMethod.MethodName',
        db.raw('COUNT(Payment.PaymentID) as TotalTransactions'),
        db.raw('COALESCE(SUM(Payment.PaymentAmount), 0) as TotalAmount')
      )
      .groupBy('PaymentMethod.MethodName')
      .orderBy('TotalAmount', 'desc');
  }

  async getSalesByCashier({ DateFrom, DateTo, BranchID }) {
    let query = db('Order')
      .join('MstUser', 'Order.UserID', 'MstUser.UserID')
      .whereIn('Order.Status', ['Completed', 'Confirmed']);

    if (BranchID) query = query.where('Order.BranchID', BranchID);
    if (DateFrom) query = query.where('Order.CreatedAt', '>=', new Date(DateFrom));
    if (DateTo) query = query.where('Order.CreatedAt', '<=', new Date(DateTo));

    return query
      .select(
        'MstUser.UserID',
        'MstUser.FullName as UserName',
        db.raw('COUNT(Order.OrderID) as TotalOrders'),
        db.raw('COALESCE(SUM(Order.GrandTotal), 0) as TotalSales')
      )
      .groupBy('MstUser.UserID', 'MstUser.FullName')
      .orderBy('TotalSales', 'desc');
  }

  async getTopSellingItems({ DateFrom, DateTo, BranchID, Limit }) {
    let query = db('OrderDetail')
      .join('Order', 'OrderDetail.OrderID', 'Order.OrderID')
      .join('Item', 'OrderDetail.ItemID', 'Item.ItemID')
      .whereIn('Order.Status', ['Completed', 'Confirmed']);

    if (BranchID) query = query.where('Order.BranchID', BranchID);
    if (DateFrom) query = query.where('Order.CreatedAt', '>=', new Date(DateFrom));
    if (DateTo) query = query.where('Order.CreatedAt', '<=', new Date(DateTo));

    return query
      .select(
        'Item.ItemID',
        'Item.ItemName',
        'Item.ItemCode',
        db.raw('SUM(OrderDetail.Qty) as TotalQty'),
        db.raw('COALESCE(SUM(OrderDetail.SubTotal), 0) as TotalSales')
      )
      .groupBy('Item.ItemID', 'Item.ItemName', 'Item.ItemCode')
      .orderBy('TotalQty', 'desc')
      .limit(Limit || 10);
  }

  async getStockReport({ BranchID, LowStockThreshold }) {
    let query = db('Stock')
      .join('Item', 'Stock.ItemID', 'Item.ItemID')
      .join('Branch', 'Stock.BranchID', 'Branch.BranchID');

    if (BranchID) query = query.where('Stock.BranchID', BranchID);

    const threshold = LowStockThreshold || 10;
    return query
      .select(
        'Stock.StockID',
        'Stock.ItemID',
        'Item.ItemName',
        'Item.ItemCode',
        'Branch.BranchName',
        'Stock.CurrentStock',
        'Stock.MinimumStock',
        db.raw('CASE WHEN Stock.CurrentStock <= COALESCE(Stock.MinimumStock, ?) THEN \'Low\' WHEN Stock.CurrentStock = 0 THEN \'Empty\' ELSE \'Ok\' END as StockStatus', [threshold])
      )
      .orderBy('Stock.CurrentStock', 'asc');
  }

  async getShiftReport({ DateFrom, DateTo, BranchID }) {
    let query = db('ShiftClosing')
      .join('Branch', 'ShiftClosing.BranchID', 'Branch.BranchID')
      .join('MstUser', 'ShiftClosing.UserID', 'MstUser.UserID')
      .join('Shift', 'ShiftClosing.ShiftID', 'Shift.ShiftID');

    if (BranchID) query = query.where('ShiftClosing.BranchID', BranchID);
    if (DateFrom) query = query.where('ShiftClosing.OpenDate', '>=', DateFrom);
    if (DateTo) query = query.where('ShiftClosing.CloseDate', '<=', DateTo);

    return query
      .select(
        'ShiftClosing.*',
        'Branch.BranchName',
        'MstUser.FullName as UserName',
        'Shift.ShiftName'
      )
      .orderBy('ShiftClosing.CreatedAt', 'desc');
  }

  async getDashboardSummary({ BranchID }) {
    const today = new Date().toISOString().split('T')[0];

    const todaySales = await db('Order')
      .where(db.raw('CAST(CreatedAt AS DATE)'), today)
      .whereIn('Status', ['Completed', 'Confirmed'])
      .modify(q => { if (BranchID) q.where('BranchID', BranchID); })
      .select(
        db.raw('COALESCE(COUNT(*), 0) as TotalOrders'),
        db.raw('COALESCE(SUM(GrandTotal), 0) as TotalSales')
      )
      .first();

    const activeOrders = await db('Order')
      .whereNotIn('Status', ['Completed', 'Cancelled', 'Refunded'])
      .modify(q => { if (BranchID) q.where('BranchID', BranchID); })
      .count('* as Count')
      .first();

    const lowStock = await db('Stock')
      .join('Item', 'Stock.ItemID', 'Item.ItemID')
      .modify(q => { if (BranchID) q.where('Stock.BranchID', BranchID); })
      .whereRaw('Stock.CurrentStock <= COALESCE(Stock.MinimumStock, 10)')
      .count('* as Count')
      .first();

    const topItems = await this.getTopSellingItems({ DateFrom: today, DateTo: today, BranchID, Limit: 5 });

    return {
      todaySales: {
        totalOrders: parseInt(todaySales.TotalOrders),
        totalSales: parseFloat(todaySales.TotalSales),
      },
      activeOrders: parseInt(activeOrders.Count),
      lowStockItems: parseInt(lowStock.Count),
      topSellingItems: topItems,
    };
  }
}

module.exports = ReportingRepository;
