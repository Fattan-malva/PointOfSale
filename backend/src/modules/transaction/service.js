const TransactionRepository = require('./repository');
const PromotionRepository = require('../promotion/repository');
const { auditLog } = require('../../helpers/audit');
const uuidv7 = require('../../helpers/uuidv7');

class TransactionService {
  constructor() {
    this.repo = new TransactionRepository();
  }

  async getOrderById(id) {
    const order = await this.repo.findOrderById(id);
    if (!order) throw new Error('Order not found');
    return order;
  }

  async getAllOrders(filters) {
    return this.repo.findOrders(filters);
  }

  async getOrderWithDetails(id) {
    const order = await this.getOrderById(id);
    const details = await this.repo.findOrderDetails(id);
    for (const d of details) {
      d.Modifiers = await this.repo.findOrderModifiers(d.OrderDetailID);
    }
    order.Items = details;
    order.Discounts = await this.repo.findOrderDiscounts(id);
    order.Payments = await this.repo.findPaymentsByOrderId(id);
    order.Kitchen = await this.repo.findKitchenByOrderId(id);
    return order;
  }

  async createOrder(data) {
    const date = new Date();
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    const prefix = `ORD-${y}${m}${d}-`;
    const lastOrder = await this.repo.findOrders({ DateFrom: `${y}-${m}-${d}T00:00:00`, DateTo: `${y}-${m}-${d}T23:59:59` });
    const seq = String(lastOrder.length + 1).padStart(4, '0');
    data.OrderNumber = prefix + seq;
    return this.repo.createOrder(data);
  }

  async updateOrder(id, data) {
    await this.getOrderById(id);
    return this.repo.updateOrder(id, data);
  }

  async updateOrderStatus(id, status) {
    const order = await this.getOrderById(id);
    const validTransitions = {
      'Draft': ['Confirmed', 'Cancelled'],
      'Confirmed': ['Preparing', 'Completed', 'Cancelled'],
      'Preparing': ['Completed', 'Cancelled'],
      'Completed': [],
      'Cancelled': [],
      'Refunded': [],
    };
    if (!validTransitions[order.Status]?.includes(status)) {
      throw new Error(`Cannot transition from ${order.Status} to ${status}`);
    }
    return this.repo.updateOrder(id, { Status: status });
  }

  async confirmOrder(id) {
    const order = await this.getOrderById(id);
    if (order.Status !== 'Draft') throw new Error('Only draft orders can be confirmed');

    const details = await this.repo.findOrderDetails(id);
    if (details.length === 0) throw new Error('Order must have at least one item');

    let subTotal = 0;
    for (const d of details) {
      const modifiers = await this.repo.findOrderModifiers(d.OrderDetailID);
      const modTotal = modifiers.reduce((sum, m) => sum + parseFloat(m.AdditionalPrice), 0);
      subTotal += parseFloat(d.SubTotal) + (parseFloat(d.Qty) * modTotal);
    }

    // Apply auto promotions
    const promos = await new PromotionRepository().findActivePromotions();
    for (const promo of promos) {
      if (promo.MinimumPurchase && subTotal < parseFloat(promo.MinimumPurchase)) continue;

      let promoDiscount = 0;
      const promoItems = await new PromotionRepository().findItemsByPromotionId(promo.PromotionID);
      const promoItemIds = promoItems.map(pi => pi.ItemID);

      if (promo.PromotionType === 'Discount') {
        if (promoItemIds.length > 0) {
          const matchedDetails = details.filter(d => promoItemIds.includes(d.ItemID));
          const itemSubTotal = matchedDetails.reduce((s, d) => s + parseFloat(d.SubTotal), 0);
          if (promo.DiscountType === 'Percentage') {
            promoDiscount = itemSubTotal * (parseFloat(promo.DiscountValue) / 100);
          } else {
            promoDiscount = parseFloat(promo.DiscountValue);
          }
        } else {
          if (promo.DiscountType === 'Percentage') {
            promoDiscount = subTotal * (parseFloat(promo.DiscountValue) / 100);
          } else {
            promoDiscount = parseFloat(promo.DiscountValue);
          }
        }
      } else if (promo.PromotionType === 'BuyXGetY' && promo.BuyQty && promo.FreeQty) {
        if (promoItemIds.length > 0) {
          const matchedDetails = details.filter(d => promoItemIds.includes(d.ItemID));
          for (const md of matchedDetails) {
            const qty = parseFloat(md.Qty);
            const freeUnits = Math.floor(qty / promo.BuyQty) * promo.FreeQty;
            const unitPrice = parseFloat(md.SubTotal) / qty;
            promoDiscount += freeUnits * unitPrice;
          }
        }
      }

      if (promo.MaximumDiscount) {
        promoDiscount = Math.min(promoDiscount, parseFloat(promo.MaximumDiscount));
      }

      if (promoDiscount > 0) {
        await this.repo.createOrderDiscount({
          OrderID: id,
          DiscountID: null,
          DiscountName: `Promo: ${promo.PromotionName}`,
          DiscountType: 'Nominal',
          DiscountValue: promoDiscount,
          DiscountAmount: promoDiscount,
        });
      }
    }

    const discounts = await this.repo.findOrderDiscounts(id);
    let discountTotal = 0;
    for (const d of discounts) {
      if (d.DiscountType === 'Percentage') {
        discountTotal += subTotal * (parseFloat(d.DiscountValue) / 100);
      } else {
        discountTotal += parseFloat(d.DiscountValue);
      }
    }

    const afterDiscount = subTotal - discountTotal;
    const taxTotal = afterDiscount * 0.11;
    const serviceCharge = 0;
    const grandTotal = afterDiscount + taxTotal + serviceCharge;

    await this.repo.updateOrder(id, {
      SubTotal: subTotal,
      DiscountTotal: discountTotal,
      TaxTotal: taxTotal,
      ServiceCharge: serviceCharge,
      GrandTotal: grandTotal,
      Status: 'Confirmed',
    });

    await auditLog({
      Module: 'Transaction',
      Action: 'ConfirmOrder',
      TableName: 'Order',
      RecordID: id,
      OldValue: { Status: order.Status, SubTotal: order.SubTotal },
      NewValue: { Status: 'Confirmed', SubTotal: subTotal, GrandTotal: grandTotal, DiscountTotal: discountTotal },
    });

    for (const d of details) {
      const item = await this.repo.findOrderDetailById(d.OrderDetailID);
      if (item) {
        await this.repo.createKitchenItem({
          OrderID: id,
          OrderDetailID: d.OrderDetailID,
          ItemName: d.ItemName,
          Qty: d.Qty,
          Status: 'Pending',
          Note: d.Note,
        });
      }
    }

    if (order.TableID) {
      const existing = await this.repo.findTableHistoryByOrderId(id);
      if (!existing) {
        await this.repo.createTableHistory({
          TableID: order.TableID,
          OrderID: id,
          StartTime: new Date(),
        });
      }
    }

    const db = require('../../db');
    const appConfig = await db('AppConfig').first();
    if (appConfig && appConfig.EnableInventory) {
      for (const d of details) {
        const recipe = await db('Recipe').where('ItemID', d.ItemID).first();
        if (recipe) {
          const ingredients = await db('RecipeDetail').where('RecipeID', recipe.RecipeID);
          for (const ing of ingredients) {
            const qtyNeeded = parseFloat(ing.Qty) * parseFloat(d.Qty);
            const stock = await db('Stock').where({ ItemID: ing.ItemID, BranchID: order.BranchID }).first();
            if (stock) {
              const before = parseFloat(stock.CurrentStock);
              const after = Math.max(0, before - qtyNeeded);
              await db('Stock').where('StockID', stock.StockID).update({ CurrentStock: after });
              await db('StockMovement').insert({
                StockMovementID: uuidv7(),
                ItemID: ing.ItemID,
                BranchID: order.BranchID,
                Qty: -qtyNeeded,
                Type: 'Out',
                ReferenceType: 'Order',
                ReferenceID: id,
                StockBefore: before,
                StockAfter: after,
                CreatedAt: db.fn.now(),
              });
            }
          }
        }
      }
    }

    return this.getOrderWithDetails(id);
  }

  async completeOrder(id) {
    const order = await this.getOrderById(id);
    if (order.PaymentStatus !== 'Paid') throw new Error('Order must be paid before completing');
    const result = await this.repo.updateOrder(id, { Status: 'Completed' });

    if (order.TableID) {
      await this.repo.closeTableHistory(id);
    }

    return result;
  }

  async cancelOrder(id) {
    const order = await this.getOrderById(id);
    if (['Completed', 'Refunded'].includes(order.Status)) {
      throw new Error('Cannot cancel completed or refunded order');
    }
    await this.repo.updateOrder(id, { Status: 'Cancelled' });

    await auditLog({
      Module: 'Transaction',
      Action: 'CancelOrder',
      TableName: 'Order',
      RecordID: id,
      OldValue: { Status: order.Status },
      NewValue: { Status: 'Cancelled' },
    });

    if (order.TableID) {
      await this.repo.closeTableHistory(id);
    }
    return this.repo.findOrderById(id);
  }

  async addItemToOrder(orderId, itemData) {
    await this.getOrderById(orderId);
    const db = require('../../db');
    const item = await db('Item').where('ItemID', itemData.ItemID).first();
    if (!item) throw new Error('Item not found');

    const subTotal = parseFloat(itemData.Qty || 1) * parseFloat(item.Price);
    return this.repo.createOrderDetail({
      OrderID: orderId,
      ItemID: item.ItemID,
      ItemName: item.ItemName,
      Qty: itemData.Qty || 1,
      Price: item.Price,
      SubTotal: subTotal,
      Note: itemData.Note,
    });
  }

  async updateOrderItem(orderId, detailId, data) {
    await this.getOrderById(orderId);
    const detail = await this.repo.findOrderDetailById(detailId);
    if (!detail) throw new Error('Order detail not found');
    if (data.Qty) data.SubTotal = parseFloat(data.Qty) * parseFloat(detail.Price);
    const updated = await this.repo.updateOrderDetail(detailId, data);

    if (data.Price && parseFloat(data.Price) !== parseFloat(detail.Price)) {
      await auditLog({
        Module: 'Transaction',
        Action: 'EditItemPrice',
        TableName: 'OrderDetail',
        RecordID: detailId,
        OldValue: { Price: detail.Price, SubTotal: detail.SubTotal },
        NewValue: { Price: data.Price, SubTotal: data.SubTotal },
      });
    }

    return updated;
  }

  async removeItemFromOrder(orderId, detailId) {
    await this.getOrderById(orderId);
    return this.repo.deleteOrderDetail(detailId);
  }

  async addModifierToItem(orderId, detailId, modifierData) {
    await this.getOrderById(orderId);
    const detail = await this.repo.findOrderDetailById(detailId);
    if (!detail) throw new Error('Order detail not found');
    return this.repo.createOrderModifier({
      OrderDetailID: detailId,
      ModifierID: modifierData.ModifierID || null,
      ModifierOptionID: modifierData.ModifierOptionID || null,
      OptionName: modifierData.OptionName,
      AdditionalPrice: modifierData.AdditionalPrice || 0,
    });
  }

  async removeModifierFromItem(orderId, detailId, modifierId) {
    await this.getOrderById(orderId);
    return this.repo.deleteOrderModifier(modifierId);
  }

  async applyDiscount(orderId, discountData) {
    await this.getOrderById(orderId);
    return this.repo.createOrderDiscount({
      OrderID: orderId,
      DiscountID: discountData.DiscountID || null,
      DiscountName: discountData.DiscountName,
      DiscountType: discountData.DiscountType,
      DiscountValue: discountData.DiscountValue,
      DiscountAmount: discountData.DiscountAmount,
    });
  }

  async removeDiscount(orderId, discountId) {
    await this.getOrderById(orderId);
    return this.repo.deleteOrderDiscount(discountId);
  }

  async processPayment(orderId, paymentData) {
    const order = await this.getOrderById(orderId);
    const existingPayments = await this.repo.findPaymentsByOrderId(orderId);
    const totalPaid = existingPayments.reduce((s, p) => s + parseFloat(p.PaymentAmount), 0) + parseFloat(paymentData.PaymentAmount);
    const grandTotal = parseFloat(order.GrandTotal);

    const payment = await this.repo.createPayment({
      OrderID: orderId,
      PaymentMethodID: paymentData.PaymentMethodID,
      PaymentAmount: paymentData.PaymentAmount,
      ReferenceNumber: paymentData.ReferenceNumber,
    });

    const newPaymentStatus = totalPaid >= grandTotal ? 'Paid' : (totalPaid > 0 ? 'Partial' : order.PaymentStatus);
    if (newPaymentStatus !== order.PaymentStatus) {
      await this.repo.updateOrder(orderId, { PaymentStatus: newPaymentStatus });
    }

    await auditLog({
      Module: 'Transaction',
      Action: 'ProcessPayment',
      TableName: 'Payment',
      RecordID: payment.PaymentID,
      OldValue: { PaymentStatus: order.PaymentStatus, TotalPaidBefore: existingPayments.reduce((s, p) => s + parseFloat(p.PaymentAmount), 0) },
      NewValue: { PaymentStatus: newPaymentStatus, PaymentAmount: paymentData.PaymentAmount, TotalPaidAfter: totalPaid },
    });

    if (order.CustomerID) {
      const points = Math.floor(grandTotal / 1000);
      await this.repo.createPointHistory({
        CustomerID: order.CustomerID,
        OrderID: orderId,
        Point: points,
        Type: 'Earn',
        Reference: `Order ${order.OrderNumber}`,
      });
    }

    return payment;
  }

  async getKitchenOrders() {
    return this.repo.findKitchenPending();
  }

  async getKitchenByOrderId(orderId) {
    await this.getOrderById(orderId);
    return this.repo.findKitchenByOrderId(orderId);
  }

  async updateKitchenItemStatus(kitchenId, status) {
    return this.repo.updateKitchenStatus(kitchenId, status);
  }

  async getAllShiftClosing(filters) {
    return this.repo.findAllShiftClosing(filters);
  }

  async getShiftClosingById(id) {
    const sc = await this.repo.findShiftClosingById(id);
    if (!sc) throw new Error('Shift closing not found');
    return sc;
  }

  async openShift(data) {
    const openDate = new Date().toISOString().split('T')[0];
    return this.repo.createShiftClosing({
      ...data,
      OpenDate: openDate,
      OpenTime: new Date(),
    });
  }

  async closeShift(id, data) {
    const sc = await this.getShiftClosingById(id);
    const date = new Date().toISOString().split('T')[0];
    const summary = await this.repo.getDailySalesSummary(date, sc.BranchID);
    return this.repo.updateShiftClosing(id, {
      CloseDate: date,
      CloseTime: new Date(),
      ClosingBalance: data.ClosingBalance,
      TotalCash: data.TotalCash || 0,
      TotalCard: data.TotalCard || 0,
      TotalEwallet: data.TotalEwallet || 0,
      TotalQR: data.TotalQR || 0,
      TotalSales: parseFloat(summary.TotalGrandTotal),
      TotalDiscount: parseFloat(summary.TotalDiscount),
      TotalTax: parseFloat(summary.TotalTax),
      Note: data.Note,
    });
  }

  async getSalesSummary(date, branchId) {
    return this.repo.getDailySalesSummary(date, branchId);
  }
}

module.exports = TransactionService;
