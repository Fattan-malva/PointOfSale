# DATABASE.md — Skema Database Sistem POS Multi-Aplikasi

> **Semua Primary Key dan Foreign Key menggunakan UUID v7** (`char(36)`), bukan auto-increment integer. UUID v7 di-generate di aplikasi (backend Node.js) sebelum insert, bukan oleh database.

Database ini dirancang sebagai **pusat ekosistem** untuk 3 aplikasi (POS Kasir, BackOffice, User APK) dan aplikasi tambahan di masa depan. Semua akses melalui REST API/GraphQL — tidak ada aplikasi yang mengakses database secara langsung.

```text
                    ┌────────────────────────────┐
                    │       SQL Server DB        │
                    └─────────────┬──────────────┘
                                  │
                          REST API / Backend
                                  │
        ┌───────────────┬─────────┴──────────────┬──────────────┐
        │               │                        │              │
        ▼               ▼                        ▼              ▼
  POS Kasir       BackOffice              User APK        Dashboard/Admin
 (Flutter)         (Flutter Web)          (Flutter)       (Opsional)
```

---

## 1. MASTER

### Branch
Data cabang untuk mendukung multi-branch.
- `BranchID` — UUID v7 (PK)

### MstRole
```
RoleID     -- UUID v7 (PK)
RoleName   -- Admin, Owner, Manager, Cashier, Kitchen, Customer
```

### MstPermission
```
PermissionID      -- UUID v7 (PK)
PermissionName    -- CanCreateOrder, CanCancelOrder, CanEditPrice,
                     CanRefund, CanViewSales, CanManageInventory,
                     CanManageEmployee, CanManagePromotion
```

### RolePermission
```
RoleID         -- UUID v7 (FK ke MstRole)
PermissionID   -- UUID v7 (FK ke MstPermission)
```
Menghindari hardcode akses; kombinasi role-permission bersifat dinamis.

### MstUser
```
UserID         -- UUID v7 (PK)
BranchID       -- UUID v7 (FK ke Branch)
RoleID         -- UUID v7 (FK ke MstRole)
Username
PasswordHash
FullName
Phone
IsActive
```
Khusus untuk pegawai (kasir, manager, owner, kitchen).

### MstCustomer
```
CustomerID          -- UUID v7 (PK)
Name
Phone
Email
PasswordHash / SocialLoginToken (Google/Apple)
Point (ringkasan, detail di CustomerPoint)
CreatedDate
```
Terpisah dari `MstUser` karena punya kebutuhan berbeda (poin, voucher, alamat, favorit, device token, login sosial).

### Category
Kategori menu.

### Item
Data menu/produk.

### Modifier / ModifierOption
Opsi tambahan pada menu (mis. level pedas, topping).

### Package / PackageDetail
Paket bundling beberapa item.

### Table
Data meja (untuk dine-in).

### Tax
Pengaturan pajak.

### Discount
Diskon umum.

### Voucher
Voucher yang dapat ditukar/digunakan pelanggan.

### PaymentMethod
Metode pembayaran yang didukung.

### Shift
Data shift kasir.

### AppConfig
```
ConfigID          -- UUID v7 (PK)
EnableKitchen
EnableInventory
EnableCustomerApp
EnableQROrdering
EnableVoucher
EnableDiscount
EnableTax
EnableServiceCharge
EnableSplitBill
EnableReservation
EnableDelivery
EnableLoyalty
EnableMembership
EnableMultiBranch
EnablePrinterBluetooth
EnableKitchenPrinter
EnableCashDrawer
Currency
DecimalDigit
```
Dibaca oleh setiap aplikasi saat login untuk menentukan fitur yang aktif.

---

## 2. TRANSACTION

```
Order
OrderDetail
OrderModifier
OrderDiscount
Payment
Kitchen          -- status KDS (Kitchen Display System)
TableHistory
ShiftClosing
VoucherHistory
PointHistory
```

---

## 3. INVENTORY

```
Supplier
Purchase
PurchaseDetail
Stock
StockMovement
Recipe
RecipeDetail
```

---

## 4. USER APK (CRM / Customer-Facing)

### CustomerAddress
```
AddressID
CustomerID
Label            -- Rumah, Kantor, Apartemen, dst.
ReceiverName
Phone
Address
Latitude
Longitude
DefaultAddress
```
Satu customer bisa memiliki banyak alamat.

### CustomerFavorite
```
FavoriteID
CustomerID
ItemID
```

### CustomerCart
```
CartID
CustomerID
ItemID
Qty
Note
```
Digunakan bila cart disimpan di server (bukan lokal).

### CustomerNotification
```
NotificationID
CustomerID
Title
Message
Read
CreatedDate
```

### CustomerPoint
```
PointHistoryID
CustomerID
Point
Type        -- Earn, Redeem, Expired
ReferenceID
```

---

## 5. PROMOTION

### Promotion
```
PromotionID
Name
StartDate
EndDate
MinimumPurchase
MaximumDiscount
PromotionType
Priority
IsActive
```

### PromotionItem
```
PromotionID
ItemID
```

Struktur generik ini mendukung berbagai tipe promosi tanpa perubahan skema:
- Buy 1 Get 1
- Happy Hour
- Diskon Menu
- Cashback
- Member Only
- Weekend Promo

---

## 6. MEDIA

### Media
```
MediaID
FileName
FilePath
MimeType
FileSize
```

### ItemMedia
```
ItemID
MediaID
SortOrder
```
Satu item/menu dapat memiliki banyak gambar dengan urutan tampil.

---

## 7. SYSTEM / LOGGING

### AuditLog
```
AuditID
UserID
Module
Action
TableName
RecordID
OldValue
NewValue
CreatedDate
```
Mencatat perubahan data kritikal (mis. kasir mengubah transaksi) agar dapat ditinjau Owner.

### UserActivity
```
ActivityID
UserID
Login
Logout
Device
IPAddress
CreatedDate
```

---

## 8. Prinsip Desain

0. **Semua Primary Key & Foreign Key menggunakan UUID v7** (bukan auto-increment integer). Generate dilakukan di layer aplikasi (`uuid` package Node.js), bukan oleh database. Alasan: keamanan (ID bisa ditebak), kompatibilitas migrasi data antar cabang, dan mencegah bentrokan ID di masa depan saat distribusi data.
1. **Satu database, banyak client** — semua aplikasi mengakses via REST API/GraphQL, tidak pernah langsung ke DB.
2. **Tidak ada hardcode role/permission** — semua melalui `RolePermission`.
3. **User vs Customer dipisah** — kebutuhan data berbeda secara signifikan.
4. **Promosi generik** — satu struktur tabel untuk berbagai jenis promo.
5. **Media terpisah dari entitas utama** — mendukung banyak gambar per item.
6. **Audit & activity log wajib** — untuk transparansi dan keamanan.
7. **AppConfig sebagai feature flag** — memungkinkan template database yang sama dipakai untuk berbagai jenis bisnis/tenant dengan fitur berbeda-beda.
8. **Siap multi-branch** dan siap ditambahkan aplikasi baru (Kitchen Display, Self Ordering Kiosk, Owner Dashboard) tanpa restrukturisasi besar.