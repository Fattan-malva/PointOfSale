# BackOffice — Task List

## 📋 Prioritas

| # | Task | Module | Priority | Status |
|---|------|--------|----------|--------|
| 1 | Dashboard — integrasi revenue & real data dari endpoint `/reports/dashboard` | Home | High | ✅ |
| 2 | **Inventory — CRUD Items** (integrasi API) | Inventory | **HIGH** | ✅ |
| 3 | **Employees — CRUD Users** (integrasi API) | Employee | **HIGH** | ✅ |
| 4 | **Orders — List & Action** (integrasi API) | Orders | High | ✅ |
| 5 | **Branch Management** — CRUD Branch (screen baru) | Core | High | ✅ |
| 6 | Reports — halaman detail per report type | Reports | Medium | ✅ |
| 7 | Profile Screen | Auth | Low | ✅ |
| 8 | Settings Screen | Auth | Low | ✅ |
| 9 | Role & Permission Management | Core | Medium | ✅ |
| 10 | Notification system | Core | Low | 🟡 |

---

## ✅ Selesai

| Task | Keterangan |
|------|------------|
| Login Screen + Auth Flow | ✅ Complete — JWT + refresh token + secure storage |
| Home/Dashboard Layout | ✅ Complete — Drawer navigasi, stats grid, quick actions |
| Router + Auth Guard | ✅ Complete — GoRouter auto-redirect |
| Core widgets (Button, Card, TextField, etc) | ✅ Complete |
| Theme (Light/Dark) | ✅ Complete |
| API Client (Dio + interceptor) | ✅ Complete |
| Secure Storage | ✅ Complete |
| **Models (7 files)** | ✅ ItemModel, CategoryModel, OrderModel, EmployeeModel, RoleModel, BranchModel, PermissionModel |
| **Inventory — CRUD Items** | ✅ Repository, Provider (StateNotifier), Screen (search, filter kategori, add/edit/delete) |
| **Employees — CRUD Users** | ✅ Repository, Provider (StateNotifier), Screen (search, add/edit, active/inactive toggle) |
| **Orders — List & Action** | ✅ Repository, Provider (StateNotifier), Screen (filter status, confirm/complete/cancel) |
| **Branch Management** | ✅ Screen baru + Repository + Provider + route + drawer menu |
| **Reports — Detail Pages** | ✅ 6 detail screens: Daily Sales, Monthly, Inventory, Revenue, Category, Employee Performance |
| **Role & Permission** | ✅ Screen + Repository + Provider — select role + assign permissions |
| **Profile Screen** | ✅ Menampilkan info user dari auth state |
| **Settings Screen** | ✅ Notifikasi & dark mode toggle |
| **Dashboard Revenue** | ✅ Integrasi `/reports/dashboard` untuk revenue real-time |
| **Routes** | ✅ Semua route terdaftar di GoRouter |

---

## 📝 Task Detail

### 1. Inventory — CRUD Items ✅
**Files:** `lib/features/inventory/`
- [x] Buat `inventory_repository.dart` — API calls ke `/items`
- [x] Buat `inventory_provider.dart` — StateNotifier untuk list + CRUD
- [x] Update `inventory_screen.dart` — ganti data dummy dengan real data
- [x] Tambah fitur: search, filter kategori, pagination
- [x] Tambah dialog: Add Item (name, price, category, image)
- [x] Tambah dialog: Edit Item
- [x] Tambah fitur: Delete Item (swipe/confirm)
- [x] Integrasi `/categories` untuk dropdown kategori

**Backend API:**
```
GET    /api/items
GET    /api/items/:id
POST   /api/items
PUT    /api/items/:id
DELETE /api/items/:id
GET    /api/categories
POST   /api/items/:id/media
```

---

### 2. Employees — CRUD Users ✅
**Files:** `lib/features/employee/`
- [x] Buat `employee_repository.dart` — API calls ke `/users`
- [x] Buat `employee_provider.dart` — StateNotifier untuk list + CRUD
- [x] Update `employee_screen.dart` — ganti data dummy
- [x] Tambah dialog: Add Employee (name, username, password, role, branch)
- [x] Tambah dialog: Edit Employee
- [x] Tambah fitur: Activate/Deactivate toggle
- [x] Integrasi `/roles` untuk dropdown role
- [x] Integrasi `/branches` untuk dropdown branch

**Backend API:**
```
GET    /api/users
GET    /api/users/:id
POST   /api/users
PUT    /api/users/:id
DELETE /api/users/:id
GET    /api/roles
GET    /api/branches
```

---

### 3. Orders — List & Action ✅
**Files:** `lib/features/orders/`
- [x] Buat `order_repository.dart` — API calls
- [x] Buat `order_provider.dart` — StateNotifier
- [x] Update `orders_screen.dart` — ganti data dummy
- [x] Implement filter (All, Pending, Confirmed, Completed, Cancelled)
- [x] Implement action: Confirm Order
- [x] Implement action: Complete Order
- [x] Implement action: Cancel Order
- [x] Implement action: View Detail Order (items, payment, etc)

**Backend API:**
```
GET    /api/orders?BranchID&Status
GET    /api/orders/:id
POST   /api/orders/:id/confirm
POST   /api/orders/:id/complete
POST   /api/orders/:id/cancel
```

---

### 4. Branch Management — CRUD (Screen Baru) ✅
**Files:** `lib/features/branch/` (baru)
- [x] Buat `branch_screen.dart` — List + CRUD
- [x] Buat `branch_repository.dart`
- [x] Buat `branch_provider.dart`
- [x] Tambah route `/branches` di router
- [x] Tambah menu "Branches" di drawer
- [x] Fitur: branch code, name, address, phone, email, active/inactive

**Backend API:**
```
GET    /api/branches
GET    /api/branches/:id
POST   /api/branches
PUT    /api/branches/:id
DELETE /api/branches/:id
```

---

### 5. Reports — Halaman Detail ✅
**Files:** `lib/features/reports/`
- [x] Buat report screen per tipe (Daily Sales, Monthly, Inventory, etc)
- [x] Integrasi endpoint `/reports/sales`
- [x] Integrasi endpoint `/reports/stock`
- [x] Integrasi endpoint `/reports/dashboard`
- [x] Charts/grafik visual

---

### 6. Role & Permission Management ✅
**Files:** `lib/features/role/` (baru)
- [x] Buat screen list roles
- [x] Buat screen assign permissions ke role
- [x] Integrasi `/roles` + `/permissions` + `/roles/:id/permissions`

---

## 🏗️ Arsitektur yang Harus Diikuti

Setiap fitur baru harus mengikuti pattern yang sudah ada:

```
features/{nama_feature}/
├── {nama_feature}_screen.dart      # UI
├── {nama_feature}_provider.dart    # StateNotifier / FutureProvider
└── repositories/
    └── {nama_feature}_repository.dart  # API calls via ApiClient
```

**Pattern:**
```
Screen → watch Provider
Provider → panggil Repository
Repository → ApiClient.get/post/put/delete → Backend API
```

**State Management:**
- `StateNotifierProvider` untuk data yang mutable (list, form, CRUD)
- `FutureProvider` untuk data sekali fetch (dashboard stats)
- `ref.watch()` di UI, `ref.read().method()` untuk action

---

## 🗺️ Status Struktur File Lengkap

```
lib/
├── main.dart                              # Entry point
├── app.dart                               # MaterialApp.router
│
├── core/
│   ├── constants/                         # ✅ AppColors, AppTypography, AppSpacing, AppShadows
│   ├── network/                           # ✅ ApiClient, ApiConfig, ApiException, ErrorMapper, SecureStorage
│   ├── storage/                           # ✅ StorageKeys
│   ├── theme/                             # ✅ AppTheme (Light/Dark)
│   ├── utils/                             # ✅ responsive.dart
│   └── widgets/                           # ✅ AppButton, AppCard, AppTextField, LoadingOverlay, ErrorView, EmptyView, StatusBadge
│
├── models/
│   ├── user_model.dart                    # ✅ UserModel
│   ├── item_model.dart                    # ✅ ItemModel (BARU)
│   ├── category_model.dart                # ✅ CategoryModel (BARU)
│   ├── order_model.dart                   # ✅ OrderModel + OrderItemModel (BARU)
│   ├── employee_model.dart                # ✅ EmployeeModel (BARU)
│   ├── role_model.dart                    # ✅ RoleModel (BARU)
│   ├── branch_model.dart                  # ✅ BranchModel (BARU)
│   └── permission_model.dart              # ✅ PermissionModel (BARU)
│
├── routes/
│   ├── app_router.dart                    # ✅ GoRouter + auth redirect + semua routes
│   └── route_names.dart                   # ✅ Route constants
│
└── features/
    ├── auth/                              # ✅ Complete (login, logout, refresh)
    │   ├── auth_provider.dart
    │   ├── auth_repository.dart
    │   └── login_screen.dart
    │
    ├── home/                              # ✅ Dashboard + drawer navigasi
    │   ├── home_screen.dart
    │   └── dashboard_provider.dart
    │
    ├── inventory/                         # ✅ CRUD Items + Categories
    │   ├── inventory_screen.dart
    │   ├── inventory_provider.dart
    │   └── repositories/
    │       └── inventory_repository.dart
    │
    ├── employee/                          # ✅ CRUD Users + Roles + Branches
    │   ├── employee_screen.dart
    │   ├── employee_provider.dart
    │   └── repositories/
    │       └── employee_repository.dart
    │
    ├── orders/                            # ✅ List + Action (confirm/complete/cancel)
    │   ├── orders_screen.dart
    │   ├── order_provider.dart
    │   └── repositories/
    │       └── order_repository.dart
    │
    ├── branch/                            # ✅ CRUD Branch (BARU)
    │   ├── branch_screen.dart
    │   ├── branch_provider.dart
    │   └── repositories/
    │       └── branch_repository.dart
    │
    ├── reports/                           # ✅ Detail pages per report type
    │   ├── reports_screen.dart
    │   ├── report_provider.dart
    │   ├── repositories/
    │   │   └── report_repository.dart
    │   └── screens/
    │       ├── daily_sales_screen.dart
    │       ├── monthly_report_screen.dart
    │       ├── inventory_summary_screen.dart
    │       ├── revenue_analytics_screen.dart
    │       ├── category_analysis_screen.dart
    │       └── employee_performance_screen.dart
    │
    ├── role/                              # ✅ Role & Permission Management (BARU)
    │   ├── role_screen.dart
    │   ├── role_provider.dart
    │   └── repositories/
    │       └── role_repository.dart
    │
    ├── profile/                           # ✅ Profile Screen (BARU)
    │   └── profile_screen.dart
    │
    └── settings/                          # ✅ Settings Screen (BARU)
        └── settings_screen.dart
```
