const db = require('../../db');
const uuidv7 = require('../../helpers/uuidv7');

class CrmRepository {
  async findCustomerById(id) {
    return db('MstCustomer').where('CustomerID', id).first();
  }

  async findCustomerByPhone(phone) {
    return db('MstCustomer').where('Phone', phone).first();
  }

  async findCustomerByEmail(email) {
    return db('MstCustomer').where('Email', email).first();
  }

  async createCustomer(data) {
    data.CustomerID = uuidv7();
    await db('MstCustomer').insert(data);
    return db('MstCustomer').where('CustomerID', data.CustomerID).first();
  }

  async updateCustomer(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('MstCustomer').where('CustomerID', id).update(data);
    return db('MstCustomer').where('CustomerID', id).first();
  }

  async findAddressesByCustomerId(customerId) {
    return db('CustomerAddress').where('CustomerID', customerId).orderBy('DefaultAddress', 'desc');
  }

  async findAddressById(id) {
    return db('CustomerAddress').where('AddressID', id).first();
  }

  async createAddress(data) {
    data.AddressID = uuidv7();
    if (data.DefaultAddress) {
      await db('CustomerAddress').where('CustomerID', data.CustomerID).update({ DefaultAddress: false });
    }
    await db('CustomerAddress').insert(data);
    return this.findAddressById(data.AddressID);
  }

  async updateAddress(id, data) {
    const existing = await this.findAddressById(id);
    if (!existing) return null;
    if (data.DefaultAddress) {
      await db('CustomerAddress').where('CustomerID', existing.CustomerID).update({ DefaultAddress: false });
    }
    data.UpdatedAt = db.fn.now();
    await db('CustomerAddress').where('AddressID', id).update(data);
    return this.findAddressById(id);
  }

  async deleteAddress(id) {
    return db('CustomerAddress').where('AddressID', id).del();
  }

  async findFavoritesByCustomerId(customerId) {
    return db('CustomerFavorite as cf')
      .join('Item', 'cf.ItemID', 'Item.ItemID')
      .where('cf.CustomerID', customerId)
      .select('cf.*', 'Item.ItemName', 'Item.Price', 'Item.ItemCode')
      .orderBy('cf.CreatedAt', 'desc');
  }

  async isFavorite(customerId, itemId) {
    const fav = await db('CustomerFavorite').where({ CustomerID: customerId, ItemID: itemId }).first();
    return !!fav;
  }

  async addFavorite(customerId, itemId) {
    await db('CustomerFavorite').insert({
      FavoriteID: uuidv7(),
      CustomerID: customerId,
      ItemID: itemId,
    });
  }

  async removeFavorite(customerId, itemId) {
    return db('CustomerFavorite').where({ CustomerID: customerId, ItemID: itemId }).del();
  }

  async findCartByCustomerId(customerId) {
    return db('CustomerCart as cc')
      .join('Item', 'cc.ItemID', 'Item.ItemID')
      .where('cc.CustomerID', customerId)
      .select('cc.*', 'Item.ItemName', 'Item.Price', 'Item.ItemCode')
      .orderBy('cc.CreatedAt');
  }

  async findCartItemById(id) {
    return db('CustomerCart').where('CartID', id).first();
  }

  async upsertCart(customerId, itemId, qty, note) {
    const existing = await db('CustomerCart').where({ CustomerID: customerId, ItemID: itemId }).first();
    if (existing) {
      await db('CustomerCart').where('CartID', existing.CartID).update({
        Qty: parseFloat(existing.Qty) + parseFloat(qty),
        Note: note || existing.Note,
        UpdatedAt: db.fn.now(),
      });
      return db('CustomerCart').where('CartID', existing.CartID).first();
    }
    const data = {
      CartID: uuidv7(),
      CustomerID: customerId,
      ItemID: itemId,
      Qty: qty,
      Note: note,
    };
    await db('CustomerCart').insert(data);
    return db('CustomerCart').where('CartID', data.CartID).first();
  }

  async updateCart(id, data) {
    data.UpdatedAt = db.fn.now();
    await db('CustomerCart').where('CartID', id).update(data);
    return db('CustomerCart').where('CartID', id).first();
  }

  async deleteCart(id) {
    return db('CustomerCart').where('CartID', id).del();
  }

  async clearCart(customerId) {
    return db('CustomerCart').where('CustomerID', customerId).del();
  }

  async findNotificationsByCustomerId(customerId) {
    return db('CustomerNotification')
      .where('CustomerID', customerId)
      .orderBy('CreatedAt', 'desc');
  }

  async markNotificationRead(id, customerId) {
    await db('CustomerNotification').where({ NotificationID: id, CustomerID: customerId }).update({ IsRead: true });
    return db('CustomerNotification').where('NotificationID', id).first();
  }

  async createNotification(data) {
    data.NotificationID = uuidv7();
    await db('CustomerNotification').insert(data);
    return db('CustomerNotification').where('NotificationID', data.NotificationID).first();
  }

  async markAllNotificationsRead(customerId) {
    return db('CustomerNotification').where({ CustomerID: customerId, IsRead: false }).update({ IsRead: true });
  }
}

module.exports = CrmRepository;
