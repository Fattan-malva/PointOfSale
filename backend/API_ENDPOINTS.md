# API Endpoints — POS Backend

**Base URL:** `http://localhost:3000/api`

## Authentication

Semua endpoint (kecuali login) memerlukan header:
```
Authorization: Bearer {accessToken}
```

---

## Core Module — `/auth`, `/branches`, `/roles`, `/permissions`, `/users`, `/app-config`

### Authentication

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/auth/user/login` | Login dengan username & password | ❌ |

**Request Body:**
```json
{
  "Username": "admin",
  "Password": "admin123"
}
```

**Response:**
```json
{
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "...",
    "user": {
      "UserID": "uuid",
      "FullName": "Super Admin",
      "Username": "admin",
      "RoleID": "uuid",
      "RoleName": "Admin",
      "BranchID": "uuid",
      "BranchName": "Cabang Utama"
    }
  }
}
```

### Branch Management

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/branches` | List semua branch | - |
| GET | `/branches/:id` | Get branch by ID | - |
| POST | `/branches` | Buat branch baru | `CanManageBranch` |
| PUT | `/branches/:id` | Update branch | `CanManageBranch` |
| DELETE | `/branches/:id` | Hapus branch | `CanManageBranch` |

### Role Management

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/roles` | List semua role | - |
| GET | `/roles/:id` | Get role by ID | - |
| POST | `/roles` | Buat role baru | `CanManageRolePermission` |
| PUT | `/roles/:id` | Update role | `CanManageRolePermission` |
| DELETE | `/roles/:id` | Hapus role | `CanManageRolePermission` |

### Permission Management

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/permissions` | List semua permission | - |
| POST | `/permissions` | Buat permission baru | `CanManageRolePermission` |
| DELETE | `/permissions/:id` | Hapus permission | `CanManageRolePermission` |

### Role-Permission Assignment

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/roles/:id/permissions` | List permission untuk role | `CanManageRolePermission` |
| POST | `/roles/:roleId/permissions/:permissionId` | Assign permission ke role | `CanManageRolePermission` |
| DELETE | `/roles/:roleId/permissions/:permissionId` | Remove permission dari role | `CanManageRolePermission` |

### User Management

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/users` | List semua user | `CanManageEmployee` |
| GET | `/users/:id` | Get user by ID | `CanManageEmployee` |
| POST | `/users` | Buat user baru | `CanManageEmployee` |
| PUT | `/users/:id` | Update user | `CanManageEmployee` |
| DELETE | `/users/:id` | Hapus user | `CanManageEmployee` |

### App Config

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/app-config` | Get config aplikasi | - |
| PUT | `/app-config` | Update config aplikasi | `CanManageAppConfig` |

---

## Master Module — Categories, Items, Modifiers, Tables, Tax, Discount, Payment Methods

### Categories

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/categories` | List semua kategori | - |
| GET | `/categories/:id` | Get kategori by ID | - |
| POST | `/categories` | Buat kategori baru | `CanManageCategory` |
| PUT | `/categories/:id` | Update kategori | `CanManageCategory` |
| DELETE | `/categories/:id` | Hapus kategori | `CanManageCategory` |

### Items

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/items` | List semua item | - |
| GET | `/items/:id` | Get item by ID | - |
| GET | `/items?categoryId=:id` | List item by kategori | - |
| POST | `/items` | Buat item baru | `CanManageItem` |
| PUT | `/items/:id` | Update item | `CanManageItem` |
| DELETE | `/items/:id` | Hapus item | `CanManageItem` |

### Modifiers

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/modifiers` | List semua modifier | - |
| GET | `/modifiers/:id` | Get modifier by ID | - |
| POST | `/modifiers` | Buat modifier baru | `CanManageModifier` |
| PUT | `/modifiers/:id` | Update modifier | `CanManageModifier` |
| DELETE | `/modifiers/:id` | Hapus modifier | `CanManageModifier` |

### Tables

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/tables` | List semua meja | - |
| GET | `/tables/:id` | Get meja by ID | - |
| POST | `/tables` | Buat meja baru | `CanManageTable` |
| PUT | `/tables/:id` | Update meja | `CanManageTable` |
| DELETE | `/tables/:id` | Hapus meja | `CanManageTable` |

### Tax

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/taxes` | List semua pajak | - |
| GET | `/taxes/:id` | Get pajak by ID | - |
| POST | `/taxes` | Buat pajak baru | `CanManageTax` |
| PUT | `/taxes/:id` | Update pajak | `CanManageTax` |
| DELETE | `/taxes/:id` | Hapus pajak | `CanManageTax` |

### Discount

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/discounts` | List semua diskon | - |
| GET | `/discounts/:id` | Get diskon by ID | - |
| POST | `/discounts` | Buat diskon baru | `CanManageDiscount` |
| PUT | `/discounts/:id` | Update diskon | `CanManageDiscount` |
| DELETE | `/discounts/:id` | Hapus diskon | `CanManageDiscount` |

### Payment Methods

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/payment-methods` | List metode pembayaran | - |
| GET | `/payment-methods/:id` | Get metode pembayaran by ID | - |
| POST | `/payment-methods` | Buat metode pembayaran | `CanManagePaymentMethod` |
| PUT | `/payment-methods/:id` | Update metode pembayaran | `CanManagePaymentMethod` |
| DELETE | `/payment-methods/:id` | Hapus metode pembayaran | `CanManagePaymentMethod` |

---

## Transaction Module — Orders, Payments

### Orders

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/orders` | List order | `CanViewOrder` |
| GET | `/orders/:id` | Get order by ID | `CanViewOrder` |
| POST | `/orders` | Buat order baru | `CanCreateOrder` |
| PUT | `/orders/:id` | Update order | `CanCreateOrder` |
| DELETE | `/orders/:id` | Cancel order | `CanCancelOrder` |
| POST | `/orders/:id/confirm` | Confirm order | `CanCreateOrder` |
| POST | `/orders/:id/complete` | Complete order | `CanCreateOrder` |

### Payments

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/payments` | List pembayaran | `CanManagePayment` |
| GET | `/payments/:id` | Get pembayaran by ID | `CanManagePayment` |
| POST | `/payments` | Buat pembayaran baru | `CanManagePayment` |
| PUT | `/payments/:id` | Update pembayaran | `CanManagePayment` |

---

## Inventory Module — Suppliers, Stock, Purchase Orders

### Suppliers

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/suppliers` | List supplier | `CanManageSupplier` |
| GET | `/suppliers/:id` | Get supplier by ID | `CanManageSupplier` |
| POST | `/suppliers` | Buat supplier baru | `CanManageSupplier` |
| PUT | `/suppliers/:id` | Update supplier | `CanManageSupplier` |
| DELETE | `/suppliers/:id` | Hapus supplier | `CanManageSupplier` |

### Stock

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/stock` | List stok | `CanManageStock` |
| PUT | `/stock/:id` | Update stok | `CanManageStock` |

### Purchase Orders

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/purchases` | List PO | `CanManagePurchase` |
| GET | `/purchases/:id` | Get PO by ID | `CanManagePurchase` |
| POST | `/purchases` | Buat PO baru | `CanManagePurchase` |
| PUT | `/purchases/:id` | Update PO | `CanManagePurchase` |

---

## CRM Module — Customers, Loyalty Points, Favorites

### Customers

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/customers` | List customer | Bearer Token |
| POST | `/customers` | Register customer baru | ❌ |
| POST | `/auth/customer/login` | Login customer | ❌ |
| GET | `/customers/me` | Get profil saya | Bearer Token |
| PUT | `/customers/me` | Update profil saya | Bearer Token |

### Customer Favorites

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/customers/me/favorites` | List favorite item | Bearer Token |
| POST | `/customers/me/favorites` | Tambah ke favorite | Bearer Token |
| DELETE | `/customers/me/favorites/:itemId` | Hapus dari favorite | Bearer Token |

---

## System Module — Audit Log, Activity Log

### Audit Log

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/audit-logs` | List audit log | `CanViewAuditLog` |
| GET | `/audit-logs/:id` | Get audit log by ID | `CanViewAuditLog` |

### Activity Log

| Method | Endpoint | Description | Permission |
|--------|----------|-------------|-----------|
| GET | `/activity-logs` | List activity log | `CanViewActivityLog` |
| GET | `/activity-logs/:id` | Get activity log by ID | `CanViewActivityLog` |

---

## Test Users (Seeded)

| Username | Password | Role | Permissions |
|----------|----------|------|-------------|
| admin | admin123 | Admin | Semua permission |
| owner | admin123 | Owner | Semua permission |
| manager | admin123 | Manager | Manage inventory, employee, order, promotion, customer |
| kasir | admin123 | Cashier | Create/cancel order, manage payment, view order |
| dapur | admin123 | Kitchen | Create order, view order |

---

## Error Response

Semua error endpoint mengembalikan format:

```json
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "Error message detail"
}
```

---

## Pagination

Untuk endpoint list, support query parameter:
- `?limit=10` — Items per page (default: 10, max: 100)
- `?offset=0` — Skip items (default: 0)

Response:
```json
{
  "data": [...],
  "total": 100,
  "limit": 10,
  "offset": 0
}
```
