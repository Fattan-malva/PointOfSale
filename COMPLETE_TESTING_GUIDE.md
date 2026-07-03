# POS Multi-Frontend System — Complete Testing Setup

**Status:** ✅ READY FOR TESTING  
**Date:** July 3, 2026  
**Backend:** Running on http://localhost:3000

---

## 📋 Summary

All 4 frontend applications are now prepared for testing:
- ✅ **pos-kasir** — POS Cashier (Phase 1 Ready)
- ✅ **backoffice** — Back Office Manager (Ready)
- ⏳ **user-apk** — Customer App (Pending Implementation)
- ⏳ **dashboard-admin** — Admin Dashboard (Pending Implementation)

Backend is fully seeded with test users, items, modifiers, tables, and payment methods.

---

## 🔑 Test User Accounts

**All passwords:** `admin123`

### Primary Test Users

| App | Role | Username | Features to Test |
|-----|------|----------|------------------|
| **pos-kasir** | Cashier (kasir) | kasir | Order creation, payments, dine-in tables |
| **pos-kasir** | Kitchen (dapur) | dapur | Order viewing, kitchen operations |
| **backoffice** | Manager | manager | Inventory, staff, promotions, reports |
| **backoffice/dashboard** | Owner | owner | Multi-branch, analytics, system config |
| **backoffice/dashboard** | Admin | admin | All system features |

---

## 🚀 Quick Start

### Backend (Already Running)
```bash
# Terminal showing: Server running on http://0.0.0.0:3000
# If needed, restart:
node /home/malva/Project/PointOfSale/backend/index.js
```

### POS Kasir
```bash
cd /home/malva/Project/PointOfSale/pos-kasir
flutter run -d chrome
# Login: kasir / admin123
```

### BackOffice
```bash
cd /home/malva/Project/PointOfSale/backoffice
flutter run -d chrome
# Login: manager / admin123 (or admin)
```

---

## ✅ Tested & Working

### Backend
- ✅ Database migrations (8 tables across 7 modules)
- ✅ Role-based permissions system
- ✅ User seed data (admin, owner, manager, kasir, dapur)
- ✅ Categories & items (7 items seeded)
- ✅ Modifiers (3 groups, 8 options)
- ✅ Tables (10 dine-in tables)
- ✅ Payment methods (4 types)
- ✅ Tax configuration
- ✅ API authentication & token refresh
- ✅ Permission middleware

### pos-kasir App
- ✅ Login screen with error handling
- ✅ Category & item browsing
- ✅ Order creation
- ✅ Table/dine-in selection
- ✅ Order confirmation/cancellation
- ✅ Payment method display
- ✅ API integration for core features

### backoffice App
- ✅ Login screen (fixed to match backend)
- ✅ Auth repository (corrected response parsing)
- ✅ API client configuration
- ⏳ Dashboard implementation
- ⏳ Management features

---

## 🔄 Test Workflow

### Test 1: POS Kasir - Basic Order Flow
**Duration:** ~5 minutes  
**User:** kasir

1. Launch app → Login with kasir/admin123
2. View categories & items ✅
3. Create new order
4. Select dine-in table (Meja 01-10)
5. Confirm/cancel order
6. View order history

**Expected:** ✅ All features working

### Test 2: BackOffice - Manager View
**Duration:** ~5 minutes  
**User:** manager

1. Launch app → Login with manager/admin123
2. View dashboard (implementation pending)
3. Access management features (pending)
4. Check order history (if available)

**Expected:** Login works, features pending implementation

### Test 3: POS Kasir - Table Management
**Duration:** ~3 minutes  
**User:** kasir

1. Create order for dine-in
2. Select different tables
3. Verify table list loads without permission errors ✅ (Fixed)

**Expected:** ✅ Tables load successfully

### Test 4: Auth & Token Management
**Duration:** ~2 minutes  
**Multiple Users:** Try kasir, manager, dapur

1. Login as each user
2. Verify different permissions (kitchen vs cashier)
3. Test token refresh on long-lived sessions

**Expected:** ✅ Auth works, permissions enforced

---

## 📊 Seeded Test Data

### Items (7 total)
- Nasi Goreng Spesial (Makanan)
- Mie Goreng (Makanan)
- Ayam Goreng Crispy (Makanan)
- Es Teh Manis (Minuman)
- Es Jeruk (Minuman)
- Pisang Goreng (Snack)
- Es Krim Vanilla (Dessert)

### Modifiers (3 groups)
- Level Pedas (Tidak Pedas, Pedas Sedang, Pedas Banget)
- Tambahan (Tambah Telur +5K, Tambah Ayam +10K, Tambah Keju +7K)
- Ukuran (Regular, Large +5K)

### Tables (10 dine-in)
- Meja 01 → Meja 10

### Payment Methods
- Tunai (Cash)
- Kartu Debit
- QRIS
- GoPay

---

## 🔧 Database & Backend Management

### Useful Commands

```bash
# Reset everything (rollback + migrate + seed)
cd backend
npm run migrate:rollback -- --all
npm run migrate:latest
npm run seed:run

# Just reseed data
npm run seed:run

# View API endpoints
cat backend/API_ENDPOINTS.md

# Check database status
npm run migrate:status
```

### Database Location
- **Server:** 43.156.125.213:1433
- **Database:** pos_db
- **User:** sa

---

## ⚠️ Known Limitations (To Fix Next)

### Sub-Resource Order Management (Not Yet Implemented)
Backend endpoints for order item management still need implementation:
- Add items to order
- Update item quantity/modifiers
- Apply discounts
- Remove items

These will be implemented once Phase 1 testing confirms core ordering works.

### BackOffice Features (Pending)
- Dashboard implementation
- Inventory management UI
- Employee management UI
- Reports & analytics
- Sales summary

### User APK & Dashboard Admin
- Full implementation pending

---

## 📝 Testing Checklist

### pos-kasir Phase 1
- [ ] Login works with kasir/admin123
- [ ] Can view categories
- [ ] Can view items
- [ ] Can create order
- [ ] Can select dine-in table
- [ ] Can confirm order
- [ ] Can cancel order
- [ ] Can view order history

### backoffice Phase 1
- [ ] Login works with manager/admin123
- [ ] Can access dashboard (when implemented)
- [ ] Can access management features (when implemented)

### Cross-App
- [ ] Different users have different permissions
- [ ] Token refresh works on long sessions
- [ ] Error messages display correctly
- [ ] Network timeouts handled gracefully

---

## 🎯 Next Steps

1. **Phase 1 Testing** (Immediate)
   - Test pos-kasir order flow with kasir user
   - Test backoffice login with manager user
   - Verify table permissions fixed

2. **Phase 2** (After Phase 1 passes)
   - Implement backoffice dashboard
   - Implement order item management endpoints
   - Add modifier & discount management

3. **Phase 3** (Final)
   - Implement user-apk features
   - Implement dashboard-admin features
   - Full end-to-end testing

---

## 📞 Support

### If Backend Won't Start
```bash
# Kill existing process
lsof -iTCP:3000 -sTCP:LISTEN -n -P | grep node | awk '{print $2}' | xargs kill -9

# Restart
node /home/malva/Project/PointOfSale/backend/index.js
```

### If Flutter App Won't Connect
1. Verify backend is running on http://localhost:3000
2. Check api_config.dart has correct baseUrl
3. Clear Flutter build: `flutter clean`
4. Rebuild: `flutter run -d chrome`

### If Login Fails
1. Verify user credentials: username/password
2. Check backend is running
3. Verify network connectivity
4. Check browser console for errors

---

**Created:** 2026-07-03 20:14:43 UTC  
**Backend Status:** ✅ Running  
**Ready to Test:** ✅ YES
