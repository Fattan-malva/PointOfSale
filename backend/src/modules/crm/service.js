const CrmRepository = require('./repository');
const repo = new CrmRepository();

class CrmService {
  // --- Auth ---
  async customerAuth(payload, app) {
    const { phone, email } = payload;
    let customer;
    if (phone) {
      customer = await repo.findCustomerByPhone(phone);
    } else if (email) {
      customer = await repo.findCustomerByEmail(email);
    } else {
      return null;
    }
    if (!customer) return null;
    const accessToken = app.generateToken(customer, 'customer');
    return { accessToken, customer };
  }

  async customerRegister(data) {
    const existing = data.Phone ? await repo.findCustomerByPhone(data.Phone) : null;
    if (existing) throw new Error('Phone already registered');
    return repo.createCustomer({
      FullName: data.name,
      Phone: data.phone,
      Email: data.email || null,
    });
  }

  // --- Profile ---
  async getProfile(customerId) {
    return repo.findCustomerById(customerId);
  }

  async updateProfile(customerId, data) {
    return repo.updateCustomer(customerId, data);
  }

  // --- Address ---
  async getAddresses(customerId) {
    return repo.findAddressesByCustomerId(customerId);
  }

  async addAddress(customerId, data) {
    return repo.createAddress({ ...data, CustomerID: customerId });
  }

  async updateAddress(customerId, addressId, data) {
    const addr = await repo.findAddressById(addressId);
    if (!addr || addr.CustomerID !== customerId) return null;
    return repo.updateAddress(addressId, data);
  }

  async deleteAddress(customerId, addressId) {
    const addr = await repo.findAddressById(addressId);
    if (!addr || addr.CustomerID !== customerId) return false;
    return repo.deleteAddress(addressId);
  }

  // --- Favorite ---
  async getFavorites(customerId) {
    return repo.findFavoritesByCustomerId(customerId);
  }

  async toggleFavorite(customerId, itemId) {
    const exists = await repo.isFavorite(customerId, itemId);
    if (exists) {
      await repo.removeFavorite(customerId, itemId);
      return { favorited: false };
    }
    await repo.addFavorite(customerId, itemId);
    return { favorited: true };
  }

  // --- Cart ---
  async getCart(customerId) {
    return repo.findCartByCustomerId(customerId);
  }

  async addToCart(customerId, data) {
    return repo.upsertCart(customerId, data.ItemID, data.Qty, data.Note);
  }

  async updateCartItem(customerId, cartId, data) {
    const item = await repo.findCartItemById(cartId);
    if (!item || item.CustomerID !== customerId) return null;
    return repo.updateCart(cartId, data);
  }

  async removeCartItem(customerId, cartId) {
    const item = await repo.findCartItemById(cartId);
    if (!item || item.CustomerID !== customerId) return false;
    return repo.deleteCart(cartId);
  }

  async clearCart(customerId) {
    return repo.clearCart(customerId);
  }

  // --- Points ---
  async getPointsSummary(customerId) {
    return repo.getCustomerTotalPoints(customerId);
  }

  async getPointHistory(customerId) {
    return repo.findPointsByCustomerId(customerId);
  }

  async redeemPoints(customerId, points, reference) {
    const summary = await repo.getCustomerTotalPoints(customerId);
    if (parseInt(points) > summary.TotalPoints) {
      throw new Error('Insufficient points');
    }
    const history = await repo.createPointHistory({
      CustomerID: customerId,
      Point: points,
      Type: 'Redeem',
      Reference: reference || 'Point Redeem',
    });
    await repo.updateCustomerPoints(customerId, summary.TotalPoints - parseInt(points));
    return history;
  }

  // --- Notification ---
  async getNotifications(customerId) {
    return repo.findNotificationsByCustomerId(customerId);
  }

  async markRead(customerId, notificationId) {
    return repo.markNotificationRead(notificationId, customerId);
  }

  async markAllRead(customerId) {
    return repo.markAllNotificationsRead(customerId);
  }
}

module.exports = CrmService;
