# BackOffice — Business Flow

## 📌 Overview

BackOffice adalah aplikasi **Flutter** (management dashboard) untuk mengelola operasional bisnis F&B. Terdiri dari 5 modul utama: **Dashboard**, **Inventory**, **Employees**, **Orders**, dan **Reports**.

---

## 1. Authentication Flow

```
┌────────────────────────────────────────────────────────────────┐
│                      LOGIN SCREEN                              │
│  Username: [___]                                               │
│  Password: [___]                                               │
│  [Login Button]                                                │
└──────────────────────────┬─────────────────────────────────────┘
                           │ POST /api/auth/user/login
                           ▼
┌────────────────────────────────────────────────────────────────┐
│  BACKEND RESPONSE                                             │
│  {                                                             │
│    data: {                                                     │
│      accessToken, refreshToken, user: {                        │
│        UserID, FullName, Username, RoleID, RoleName,           │
│        BranchID, BranchName                                     │
│      }                                                         │
│    }                                                           │
│  }                                                             │
└──────────────────────────┬─────────────────────────────────────┘
                           ▼
┌────────────────────────────────────────────────────────────────┐
│  SECURE STORAGE (disimpan)                                     │
│  • accessToken + refreshToken                                  │
│  • userId, userEmail, userName, userRole                       │
│  • branchId ← untuk filter data per cabang                     │
└──────────────────────────┬─────────────────────────────────────┘
                           ▼
┌────────────────────────────────────────────────────────────────┐
│  REDIRECT KE HOME SCREEN (if authenticated)                    │
│  Auto-redirect ke LOGIN (if not)                               │
└────────────────────────────────────────────────────────────────┘
```

**Files:**
- `lib/features/auth/login_screen.dart` — UI login
- `lib/features/auth/auth_provider.dart` — StateNotifier (AuthState)
- `lib/features/auth/auth_repository.dart` — API calls login/logout/refresh
- `lib/core/network/api_client.dart` — Dio singleton + JWT interceptor + auto refresh
- `lib/core/network/secure_storage.dart` — FlutterSecureStorage
- `lib/models/user_model.dart` — UserModel (id, email, name, role, branchId)

---

## 2. Dashboard Flow (Home)

```
┌────────────────────────────────────────────────────────────────┐
│                      HOME SCREEN                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ AppBar: Title + Notification Icon + Profile Avatar       │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ Drawer (Navigation):                                      │  │
│  │  • Dashboard (active)                                     │  │
│  │  • Inventory                                              │  │
│  │  • Employees                                              │  │
│  │  • Orders                                                 │  │
│  │  • Reports                                                │  │
│  │  • Logout                                                 │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ BODY (Dashboard tab):                                     │  │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐                    │  │
│  │  │Orders│ │Revenue│ │Items │ │Empl. │                    │  │
│  │  │  150 │ │ Rp2jt │ │  45  │ │  12  │                    │  │
│  │  └──────┘ └──────┘ └──────┘ └──────┘                    │  │
│  │                                                           │  │
│  │  Quick Actions: [Add Item] [Add Employee]                 │  │
│  │                 [View Orders] [Reports]                   │  │
│  │                                                           │  │
│  │  Recent Orders: (list 5 order terakhir)                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

**Data Flow Dashboard:**
```
Dashboard Provider
  ↓
GET /api/orders?limit=1  → totalOrders
GET /api/items?limit=1   → activeItems  
GET /api/users?limit=1   → totalEmployees
  ↓
DashboardStats { totalOrders, todayRevenue, activeItems, totalEmployees }
```

**Files:**
- `lib/features/home/home_screen.dart` — Main screen + drawer + dashboard tab
- `lib/features/home/dashboard_provider.dart` — FutureProvider fetching stats
- `lib/routes/app_router.dart` — GoRouter config + auth redirect

---

## 3. Inventory Flow ⬜ (STATIC — placeholder)

```
┌────────────────────────────────────────────────────────────────┐
│                   INVENTORY SCREEN  ⬜                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Header: "Inventory" + [+ Add Item] button                │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ [Search items...___________________________________]     │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ ┌──────────────────────────────────────────────────────┐ │  │
│  │ │ Item 1     Category • Rp 10.000            [✏️ Edit] │ │  │
│  │ │ Item 2     Category • Rp 20.000            [✏️ Edit] │ │  │
│  │ │ Item 3     Category • Rp 30.000            [✏️ Edit] │ │  │
│  │ │ ...                                                  │ │  │
│  │ └──────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                               │
│  [Add Item Dialog]                                            │
│  ┌───────────────────────────────────────┐                    │
│  │ Item Name: [____]                     │                    │
│  │ Price:     [____]                     │                    │
│  │ Category:  [____]                     │                    │
│  │ [Cancel] [Save]                       │                    │
│  └───────────────────────────────────────┘                    │
│                                                               │
│  [Edit Item Dialog]                                           │
│  ┌───────────────────────────────────────┐                    │
│  │ Item Name: [Item X]                   │                    │
│  │ Price:     [Rp X]                     │                    │
│  │ [Cancel] [Update]                     │                    │
│  └───────────────────────────────────────┘                    │
└────────────────────────────────────────────────────────────────┘
```

**Status: ⬜ STATIC** — Data dummy, belum connect ke API backend.

**Backend API yang perlu diintegrasikan:**
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/api/items` | List semua item |
| POST | `/api/items` | Create item |
| PUT | `/api/items/:id` | Update item |
| DELETE | `/api/items/:id` | Delete item |
| GET | `/api/categories` | List kategori |
| POST | `/api/items/:id/media` | Upload gambar item |

**File:** `lib/features/inventory/inventory_screen.dart`

---

## 4. Employees Flow ⬜ (STATIC — placeholder)

```
┌────────────────────────────────────────────────────────────────┐
│                   EMPLOYEES SCREEN  ⬜                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Header: "Employees" + [+ Add Employee] button           │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ [Search employees..._______________________________]     │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ ┌──────────────────────────────────────────────────────┐ │  │
│  │ │ 👤 Super Admin       Admin    [Active]      [✏️]    │ │  │
│  │ │ 👤 Branch Manager    Manager  [Active]      [✏️]    │ │  │
│  │ │ 👤 Kasir 1           Cashier  [Active]      [✏️]    │ │  │
│  │ │ 👤 Staff Dapur       Kitchen  [Active]      [✏️]    │ │  │
│  │ │ 👤 Kasir 2           Cashier  [Active]      [✏️]    │ │  │
│  │ └──────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                               │
│  [Add Employee Dialog]                                        │
│  ┌───────────────────────────────────────┐                    │
│  │ Full Name: [____]                     │                    │
│  │ Username:  [____]                     │                    │
│  │ Password:  [____]                     │                    │
│  │ Role:      [▼ Admin]                  │                    │
│  │ Branch:    [▼ Cabang]                 │                    │
│  │ [Cancel] [Save]                       │                    │
│  └───────────────────────────────────────┘                    │
└────────────────────────────────────────────────────────────────┘
```

**Status: ⬜ STATIC** — Data dummy, belum connect ke API backend.

**Backend API yang perlu diintegrasikan:**
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/api/users` | List semua user (employee) |
| POST | `/api/users` | Create user |
| PUT | `/api/users/:id` | Update user |
| DELETE | `/api/users/:id` | Delete user |
| GET | `/api/roles` | List roles untuk dropdown |
| GET | `/api/branches` | List branches untuk dropdown |

**File:** `lib/features/employee/employee_screen.dart`

---

## 5. Orders Flow ⬜ (STATIC — placeholder)

```
┌────────────────────────────────────────────────────────────────┐
│                    ORDERS SCREEN  ⬜                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Header: "Orders"                                         │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ Filter: [All] [Pending] [Confirmed] [Completed]          │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ ┌──────────────────────────────────────────────────────┐ │  │
│  │ │ Order #2026000   Table M1 • pending    [PENDING]     │ │  │
│  │ │  ▶ Item 1                    Rp 25.000               │ │  │
│  │ │    Item 2                    Rp 30.000               │ │  │
│  │ │    ─────────────────────────────────                  │ │  │
│  │ │    Total                    Rp 55.000                │ │  │
│  │ │                           [Cancel] [Process]         │ │  │
│  │ └──────────────────────────────────────────────────────┘ │  │
│  │ ┌──────────────────────────────────────────────────────┐ │  │
│  │ │ Order #2026001   Table M2 • confirmed  [CONFIRMED]   │ │  │
│  │ │  ...                                                  │ │  │
│  │ └──────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

**Status: ⬜ STATIC** — Data dummy, belum connect ke API backend.

**Backend API yang perlu diintegrasikan:**
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/api/orders?BranchID=xxx` | List orders per branch |
| GET | `/api/orders/:id` | Get order detail |
| POST | `/api/orders/:id/confirm` | Confirm order |
| POST | `/api/orders/:id/complete` | Complete order |
| POST | `/api/orders/:id/cancel` | Cancel order |

**File:** `lib/features/orders/orders_screen.dart`

---

## 6. Reports Flow ⬜ (STATIC — placeholder)

```
┌────────────────────────────────────────────────────────────────┐
│                    REPORTS SCREEN  ⬜                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Header: "Reports"                                        │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ ┌──────────────────────────────────────────────────────┐ │  │
│  │ │ 📅 Daily Sales         Today's sales report    >    │ │  │
│  │ │ 📆 Monthly Report      Monthly performance    >    │ │  │
│  │ │ 📦 Inventory Summary   Stock levels & alerts >    │ │  │
│  │ │ 👥 Employee Perform.   Staff activity        >    │ │  │
│  │ │ 📈 Revenue Analytics   Revenue trends        >    │ │  │
│  │ │ 🥧 Category Analysis   Sales by category     >    │ │  │
│  │ └──────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

**Status: ⬜ STATIC** — Menu cards, belum ada halaman detail.

**Backend API yang perlu diintegrasikan:**
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/api/reports/sales?BranchID=xxx&DateFrom=...&DateTo=...` | Sales report |
| GET | `/api/reports/sales/by-payment` | Sales by payment method |
| GET | `/api/reports/sales/by-cashier` | Sales by cashier |
| GET | `/api/reports/sales/top-items` | Top items |
| GET | `/api/reports/stock` | Stock report |
| GET | `/api/reports/dashboard` | Dashboard summary |

**File:** `lib/features/reports/reports_screen.dart`

---

## 7. Navigation & Routing Flow

```
┌────────────────────────────────────────────────────────────────┐
│  APP START                                                     │
│      │                                                        │
│      ▼                                                        │
│  AuthState._init() ← cek token di SecureStorage               │
│      │                                                        │
│      ├── Token valid → GoRouter redirect → /home              │
│      └── No token  → GoRouter redirect → /login               │
│                                                                │
│  ROUTES:                                                       │
│  ┌──────────────────────────────────────────┐                  │
│  │  /login   → LoginScreen                   │                  │
│  │  /home    → HomeScreen (dengan tabs)      │                  │
│  │  /profile → ProfileScreen (TODO)          │                  │
│  └──────────────────────────────────────────┘                  │
│                                                                │
│  NAVIGATION (Drawer di HomeScreen):                            │
│  ┌──────────────────────────────────────────┐                  │
│  │  0: Dashboard  → DashboardTab            │                  │
│  │  1: Inventory  → InventoryScreen         │                  │
│  │  2: Employees  → EmployeeScreen          │                  │
│  │  3: Orders     → OrdersScreen            │                  │
│  │  4: Reports    → ReportsScreen           │                  │
│  └──────────────────────────────────────────┘                  │
└────────────────────────────────────────────────────────────────┘
```

---

## 8. Struktur File Lengkap

```
lib/
├── main.dart                              # Entry point
├── app.dart                               # MaterialApp.router
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                # Warna tema
│   │   ├── app_shadows.dart               # Shadow styles
│   │   ├── app_spacing.dart               # Spacing constants
│   │   └── app_typography.dart            # Text styles
│   ├── network/
│   │   ├── api_client.dart                # Dio singleton + JWT interceptor + auto refresh
│   │   ├── api_config.dart                # Base URL config
│   │   ├── api_exception.dart             # Exception classes
│   │   ├── error_mapper.dart              # DioException → ApiException
│   │   └── secure_storage.dart            # FlutterSecureStorage wrapper
│   ├── storage/
│   │   └── storage_keys.dart              # Key constants
│   ├── theme/
│   │   └── app_theme.dart                 # Light/Dark ThemeData
│   ├── utils/
│   └── widgets/
│       ├── app_button.dart                # Button reusable
│       ├── app_card.dart                  # Card reusable
│       ├── app_text_field.dart            # TextField reusable
│       ├── empty_view.dart                # Empty state
│       ├── error_view.dart                # Error state
│       ├── loading_overlay.dart           # Loading overlay
│       └── status_badge.dart              # Status badge chip
│
├── models/
│   └── user_model.dart                    # UserModel (id, email, name, role, branchId)
│
├── routes/
│   ├── app_router.dart                    # GoRouter + auth redirect
│   └── route_names.dart                   # Route constants
│
└── features/
    ├── auth/
    │   ├── auth_provider.dart             # AuthNotifier (StateNotifier)
    │   ├── auth_repository.dart           # Login/logout/refresh API
    │   └── login_screen.dart              # Login UI ✅ COMPLETE
    ├── home/
    │   ├── home_screen.dart               # Dashboard + drawer navigasi ✅ COMPLETE
    │   └── dashboard_provider.dart        # DashboardStats API ⚠️ partial
    ├── employee/
    │   └── employee_screen.dart           # ⬜ STATIC
    ├── inventory/
    │   └── inventory_screen.dart          # ⬜ STATIC
    ├── orders/
    │   └── orders_screen.dart             # ⬜ STATIC
    └── reports/
        └── reports_screen.dart            # ⬜ STATIC
```

---

## 9. Status Legend

| Icon | Status | Arti |
|------|--------|------|
| ✅ | **COMPLETE** | Sudah terimplementasi penuh (UI + API) |
| ⚠️ | **PARTIAL** | Ada implementasi tapi belum sempurna |
| ⬜ | **STATIC** | Hanya UI placeholder, belum connect API |
| 🟡 | **TODO** | Belum dikerjakan |

---

## 10. Alur Data End-to-End

```
USER LOGIN → SecureStorage (branchId)
    │
    ├── Dashboard → GET /orders, /items, /users
    │
    ├── Inventory ⬜ → Perlu: GET/POST/PUT/DELETE /items + /categories
    │
    ├── Employees ⬜ → Perlu: GET/POST/PUT/DELETE /users + /roles + /branches
    │
    ├── Orders ⬜ → Perlu: GET /orders + POST confirm/complete/cancel
    │
    └── Reports ⬜ → Perlu: GET /reports/sales + /reports/stock + dll
```
