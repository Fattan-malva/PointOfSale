const CrmService = require('./service');
const { userActivity } = require('../../helpers/audit');

module.exports = async function (app) {
  const svc = new CrmService();

  app.post('/auth/customer/login', async (req, reply) => {
    const { phone, email } = req.body;
    if (!phone && !email) {
      return reply.status(400).send({ error: 'Phone or email required' });
    }
    const result = await svc.customerAuth({ phone, email }, app);
    if (!result) return reply.status(401).send({ error: 'Customer not found' });

    const refreshToken = await app.generateRefreshToken(result.customer.CustomerID, 'Customer');

    await userActivity({
      UserID: result.customer.CustomerID,
      UserType: 'Customer',
      Action: 'Login',
      Device: req.headers['user-agent'],
      IPAddress: req.ip,
    });

    return {
      accessToken: result.accessToken,
      refreshToken,
      customer: {
        CustomerID: result.customer.CustomerID,
        FullName: result.customer.FullName,
        Phone: result.customer.Phone,
        Email: result.customer.Email,
      },
    };
  });

  app.post('/auth/customer/register', async (req, reply) => {
    const { name, phone, email } = req.body;
    if (!name || !phone) {
      return reply.status(400).send({ error: 'Name and phone required' });
    }
    try {
      const customer = await svc.customerRegister({ name, phone, email });
      return { data: customer };
    } catch (e) {
      return reply.status(409).send({ error: e.message });
    }
  });

  app.register(async function (authenticated) {
    authenticated.addHook('preHandler', app.authenticate);

    authenticated.addHook('preHandler', async (req) => {
      if (req.user?.type !== 'customer') {
        throw app.httpErrors.forbidden('Customer access required');
      }
    });

    // Profile
    authenticated.get('/customers/me', async (req) => {
      const profile = await svc.getProfile(req.user.id);
      return { data: profile };
    });

    authenticated.put('/customers/me', async (req, reply) => {
      const { name, phone, email } = req.body;
      if (!name && !phone && !email) {
        return reply.status(400).send({ error: 'No fields to update' });
      }
      const profile = await svc.updateProfile(req.user.id, { FullName: name, Phone: phone, Email: email });
      return { data: profile };
    });

    // Address
    authenticated.get('/customers/me/addresses', async (req) => {
      const addresses = await svc.getAddresses(req.user.id);
      return { data: addresses };
    });

    authenticated.post('/customers/me/addresses', async (req, reply) => {
      const { label, receiverName, phone, address, latitude, longitude, defaultAddress } = req.body;
      if (!receiverName || !address) {
        return reply.status(400).send({ error: 'ReceiverName and Address required' });
      }
      const addr = await svc.addAddress(req.user.id, {
        Label: label || 'Other',
        ReceiverName: receiverName,
        Phone: phone,
        Address: address,
        Latitude: latitude,
        Longitude: longitude,
        DefaultAddress: defaultAddress || false,
      });
      return { data: addr };
    });

    authenticated.put('/customers/me/addresses/:id', async (req, reply) => {
      const { label, receiverName, phone, address, latitude, longitude, defaultAddress } = req.body;
      const addr = await svc.updateAddress(req.user.id, req.params.id, {
        Label: label,
        ReceiverName: receiverName,
        Phone: phone,
        Address: address,
        Latitude: latitude,
        Longitude: longitude,
        DefaultAddress: defaultAddress,
      });
      if (!addr) return reply.status(404).send({ error: 'Address not found' });
      return { data: addr };
    });

    authenticated.delete('/customers/me/addresses/:id', async (req, reply) => {
      const ok = await svc.deleteAddress(req.user.id, req.params.id);
      if (!ok) return reply.status(404).send({ error: 'Address not found' });
      return { message: 'Deleted' };
    });

    // Favorite
    authenticated.get('/customers/me/favorites', async (req) => {
      const favorites = await svc.getFavorites(req.user.id);
      return { data: favorites };
    });

    authenticated.post('/customers/me/favorites/:itemId', async (req) => {
      return svc.toggleFavorite(req.user.id, req.params.itemId);
    });

    authenticated.delete('/customers/me/favorites/:itemId', async (req) => {
      return svc.toggleFavorite(req.user.id, req.params.itemId);
    });

    // Cart
    authenticated.get('/customers/me/cart', async (req) => {
      const cart = await svc.getCart(req.user.id);
      return { data: cart };
    });

    authenticated.post('/customers/me/cart', async (req, reply) => {
      const { itemId, qty, note } = req.body;
      if (!itemId || !qty) {
        return reply.status(400).send({ error: 'ItemID and Qty required' });
      }
      const item = await svc.addToCart(req.user.id, { ItemID: itemId, Qty: qty, Note: note });
      return { data: item };
    });

    authenticated.put('/customers/me/cart/:id', async (req, reply) => {
      const { qty, note } = req.body;
      const item = await svc.updateCartItem(req.user.id, req.params.id, { Qty: qty, Note: note });
      if (!item) return reply.status(404).send({ error: 'Cart item not found' });
      return { data: item };
    });

    authenticated.delete('/customers/me/cart/:id', async (req, reply) => {
      const ok = await svc.removeCartItem(req.user.id, req.params.id);
      if (!ok) return reply.status(404).send({ error: 'Cart item not found' });
      return { message: 'Removed' };
    });

    authenticated.delete('/customers/me/cart', async (req) => {
      await svc.clearCart(req.user.id);
      return { message: 'Cart cleared' };
    });

    // Notification
    authenticated.get('/customers/me/notifications', async (req) => {
      const notifications = await svc.getNotifications(req.user.id);
      return { data: notifications };
    });

    authenticated.put('/customers/me/notifications/:id/read', async (req, reply) => {
      const notif = await svc.markRead(req.user.id, req.params.id);
      if (!notif) return reply.status(404).send({ error: 'Notification not found' });
      return { data: notif };
    });

    authenticated.put('/customers/me/notifications/read', async (req) => {
      await svc.markAllRead(req.user.id);
      return { message: 'All marked as read' };
    });
  }, { prefix: '' });
};
