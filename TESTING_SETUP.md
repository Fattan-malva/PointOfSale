# Testing Setup — POS Multi-Frontend System

**Date:** July 3, 2026  
**Status:** Ready for Testing

---

## Backend Status ✅

**Server:** Running on `http://localhost:3000`  
**Database:** SQL Server - seeded with test data  
**API Documentation:** See `backend/API_ENDPOINTS.md`

### Test Users Available

All users use password: `admin123`

| Role | Username | Permissions | Use Case |
|------|----------|-------------|----------|
| Admin | admin | All permissions | System administration |
| Owner | owner | All permissions | Business owner (multi-branch) |
| Manager | manager | Inventory, orders, staff, promotions | Branch manager |
| Cashier | kasir | Orders, payments | POS operator |
| Kitchen | dapur | Orders, kitchen view | Kitchen staff |

### Seeded Test Data

- **Items:** 7 items across 4 categories (Makanan, Minuman, Snack, Dessert)
- **Modifiers:** 3 modifier groups with 8 options total
- **Tables:** 10 tables (Meja 01-10) for dine-in
- **Payment Methods:** Cash, Debit Card, QRIS, GoPay
- **Shifts:** Pagi (07:00-15:00), Siang (15:00-23:00)
- **Tax:** PPN 11%

---

## Frontend Applications

### 1. pos-kasir (POS Cashier)
**Location:** `/home/malva/Project/PointOfSale/pos-kasir`  
**Platform:** Flutter Web/Mobile  
**Recommended User:** kasir (Cashier)

**Features Ready:**
- ✅ Login
- ✅ Category & Item browsing
- ✅ Order creation
- ✅ Order management (confirm/cancel)
- ✅ Table/dine-in selection
- ⚠️ Order item management (backend sub-resources pending)
- ⚠️ Modifiers (backend sub-resources pending)
- ⚠️ Discounts (backend sub-resources pending)

**To Run:**
```bash
cd pos-kasir
flutter run -d chrome  # or linux, windows, ios, android
```

### 2. backoffice (Back Office Management)
**Location:** `/home/malva/Project/PointOfSale/backoffice`  
**Platform:** Flutter Web  
**Recommended User:** manager or admin

**Features Ready:**
- ✅ Login framework
- ⚠️ Dashboard (pending implementation)
- ⚠️ Inventory management (pending implementation)
- ⚠️ Employee management (pending implementation)
- ⚠️ Reports (pending implementation)

**To Run:**
```bash
cd backoffice
flutter run -d chrome
```

### 3. user-apk (Customer Mobile App)
**Location:** `/home/malva/Project/PointOfSale/user-apk`  
**Platform:** Flutter Mobile  
**For:** End customers

**Status:** Pending full implementation

### 4. dashboard-admin (Admin Dashboard)
**Location:** `/home/malva/Project/PointOfSale/dashboard-admin`  
**Platform:** Flutter Web  
**Recommended User:** owner or admin

**Status:** Pending full implementation

---

## API Endpoints Reference

### Core Authentication
- `POST /auth/user/login` — Employee login
- `POST /auth/refresh` — Refresh access token
- `POST /auth/logout` — Logout (optional backend support)

### Master Data (Read)
- `GET /categories` — List categories
- `GET /categories/:id` — Get category details
- `GET /items` — List items (supports `?categoryId=xxx`)
- `GET /items/:id` — Get item details
- `GET /modifiers` — List modifiers
- `GET /tables` — List tables
- `GET /payment-methods` — List payment methods

### Orders
- `GET /orders` — List orders
- `GET /orders/:id` — Get order details
- `POST /orders` — Create new order
- `PUT /orders/:id` — Update order
- `POST /orders/:id/confirm` — Confirm order
- `POST /orders/:id/complete` — Complete order
- `DELETE /orders/:id` — Cancel order

### Payments
- `POST /payments` — Process payment
- `GET /payment-methods` — List available payment methods

---

## Backend Sub-Resources (Pending Implementation)

These endpoints need to be implemented in the backend for full functionality:

```
POST   /orders/:id/items                                  — Add item to order
PUT    /orders/:id/items/:detailId                        — Update order item quantity/price
DELETE /orders/:id/items/:detailId                        — Remove item from order
POST   /orders/:id/items/:detailId/modifiers              — Add modifier to order item
DELETE /orders/:id/items/:detailId/modifiers/:modifierId  — Remove modifier from order item
POST   /orders/:id/discounts                              — Apply discount to order
DELETE /orders/:id/discounts/:discountId                  — Remove discount from order
```

Once these are implemented, uncomment the corresponding methods in:
- `pos-kasir/lib/features/order/repositories/order_repository.dart`
- `pos-kasir/lib/features/order/order_provider.dart`

---

## Testing Workflow

### Phase 1: POS Kasir Testing (Immediate)
1. Start backend: `node backend/index.js` (or already running)
2. Run pos-kasir: `cd pos-kasir && flutter run -d chrome`
3. Login with: `kasir` / `admin123`
4. Test:
   - View categories & items ✅
   - Create orders ✅
   - Select dine-in tables ✅
   - Confirm/cancel orders ✅

### Phase 2: BackOffice Testing (After Phase 1)
1. Run backoffice: `cd backoffice && flutter run -d chrome`
2. Login with: `manager` / `admin123`
3. Test dashboard and management features

### Phase 3: User APK Testing
- TBD: Full implementation pending

### Phase 4: Dashboard Admin Testing
- TBD: Full implementation pending

---

## Common Issues & Solutions

### Issue: Permission Denied when viewing tables
**Solution:** Already fixed! Cashier and Kitchen roles now have `CanViewTable` permission.

### Issue: Order items not updating
**Solution:** Backend sub-resources not yet implemented. See section above.

### Issue: Backend connection refused
**Solution:** 
```bash
# Kill existing process
lsof -iTCP:3000 -sTCP:LISTEN -n -P | grep node | awk '{print $2}' | xargs kill -9

# Restart backend
node backend/index.js
```

---

## Database Commands

```bash
# Full reset (rollback + migrate + seed)
npm run migrate:rollback -- --all && npm run migrate:latest && npm run seed:run

# Just reseed data
npm run seed:run

# View migrations status
npm run migrate:status
```

---

## Next Steps

1. ✅ Backend ready
2. ✅ pos-kasir ready for Phase 1 testing
3. 📋 Implement backoffice features
4. 📋 Implement sub-resource order management endpoints
5. 📋 Implement user-apk
6. 📋 Implement dashboard-admin

---

**Last Updated:** 2026-07-03 20:11  
**Ready for Testing:** YES ✅
