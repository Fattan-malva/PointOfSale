# TASK.md — Task Breakdown Pengembangan

Status: `[ ]` belum dikerjakan · `[~]` sedang dikerjakan · `[x]` selesai

**Stack yang dipakai:**
- Backend: **Fastify** (Node.js)
- Database: **SQL Server**
- Migration/Query Builder: **Knex.js** (mendukung dialect `mssql`, punya CLI migration bawaan)
- Auth: `@fastify/jwt`

Setiap task "Tabel & API" dipecah menjadi dua sub-langkah: **Migration** (buat/ubah skema lewat Knex) dan **API** (buat route/handler Fastify). Migration selalu dibuat lebih dulu, dijalankan (`knex migrate:latest`), baru API di atasnya dikerjakan.

---

## Fase 0 — Setup Struktur Proyek (5 Folder)

- [x] Buat 5 folder sibling di root: `backend/`, `pos-kasir/`, `backoffice/`, `user-apk/`, `dashboard-admin/`
- [x] **`backend/`** — init project Node.js + install `fastify`, `@fastify/jwt`, `@fastify/cors`, `knex`, `mssql`, `dotenv`
- [x] **`backend/`** — Setup struktur folder modular: `src/modules/{core,master,transaction,inventory,crm,reporting,system}`, `src/plugins`, `src/db`, `migrations/`, `seeds/`
- [x] **`backend/`** — Setup koneksi Knex ke SQL Server (`knexfile.js` dengan config `dev`, `staging`, `production`)
- [x] **`backend/`** — Setup skrip npm: `migrate:make`, `migrate:latest`, `migrate:rollback`, `seed:run`
- [x] **`backend/`** — Setup Fastify plugin dasar: logger, error handler global, validasi (schema-based, mis. pakai JSON Schema bawaan Fastify)
- [x] **`backend/`** — Setup autentikasi dasar JWT (`@fastify/jwt`) — dua strategi terpisah: token untuk `MstUser` (pegawai) dan token untuk `MstCustomer` (pelanggan)
- [x] **`backend/`** — Setup `.env.example` (koneksi DB, JWT secret, port, dsb.)
- [x] **`pos-kasir/`** — `flutter create` project baru, terapkan tema dasar dari `DESIGN.md`
- [x] **`backoffice/`** — `flutter create` project baru, terapkan tema dasar dari `DESIGN.md`
- [x] **`user-apk/`** — `flutter create` project baru, terapkan tema dasar dari `DESIGN.md`
- [x] **`dashboard-admin/`** — `flutter create` project baru, terapkan tema dasar dari `DESIGN.md`
- [x] Setiap folder Flutter dikonfigurasi agar bisa build minimal ke web (untuk BackOffice/Dashboard) dan mobile (untuk POS Kasir/User APK) sesuai kebutuhan masing-masing
- [x] Template struktur `lib/` Flutter disamakan di `DESIGN.md` section 10 dan mulai diterapkan ke 4 aplikasi frontend

## Fase 1 — Core Module

- [x] Migration: `branch`
- [x] Migration: `mst_role`, `mst_permission`, `role_permission`
- [x] Migration: `mst_user`
- [x] Migration: `app_config`
- [x] API (Fastify route): `Branch` CRUD
- [x] API: `MstRole`, `MstPermission`, `RolePermission` CRUD
- [x] API: `MstUser` CRUD + login pegawai (`POST /auth/user/login`)
- [x] Plugin/decorator Fastify: middleware pengecekan permission (`fastify.decorate('checkPermission', ...)`) dipakai di `preHandler` setiap route yang butuh proteksi
- [x] API: `AppConfig` CRUD + endpoint `GET /app-config` (dibaca client saat login)
- [x] Seed data awal: role default (Admin, Owner, Manager, Cashier, Kitchen, Customer) + permission default

## Fase 2 — Master Module ✅

- [x] Migration + API: `Category`, `Item`
- [x] Migration + API: `Modifier`, `ModifierOption`
- [x] Migration + API: `ItemModifier`, `PackageDetail`
- [x] Migration + API: `Table`, `Tax`, `Discount`, `Voucher`, `PaymentMethod`
- [x] Migration + API: `Shift`
- [x] Migration + API: `MstCustomer` (terpisah dari `MstUser`)
- [x] Migration + API: `Media`, `ItemMedia`

## Fase 3 — Transaction Module ✅

- [x] Migration + API: `Order`, `OrderDetail`, `OrderModifier`, `OrderDiscount`
- [x] Migration + API: `Payment`
- [x] Migration + API: `Kitchen` (status KDS)
- [x] Migration + API: `TableHistory`
- [x] Migration + API: `ShiftClosing`, `VoucherHistory`, `PointHistory`
- [x] Integrasi `Promotion` + `PromotionItem` ke service pembuatan order (hitung diskon otomatis)
- [x] Service: logika pembayaran + point & voucher
- [x] Implementasi `AuditLog` pada aksi kritikal
- [x] Tax rate diambil dari tabel Tax (tidak hardcode 11%)
- [x] Pagination (limit/offset) di semua list endpoints
- [~] Build UI POS Kasir (Flutter) — konsumsi API di atas
- [~] POS Kasir membaca `GET /app-config` saat login

## Fase 4 — Inventory Module ✅

- [x] Migration + API: `Supplier`
- [x] Migration + API: `Purchase`, `PurchaseDetail`
- [x] Migration + API: `Stock`, `StockMovement`
- [x] Migration + API: `Recipe`, `RecipeDetail`
- [x] Service: logika pengurangan stok otomatis saat order (berdasarkan resep) — aktif jika `EnableInventory`

## Fase 5 — BackOffice App

- [~] Modul manajemen: Master data (menu, kategori, modifier, dsb.) — API sudah siap
- [~] Modul manajemen: Karyawan & Role/Permission — API sudah siap
- [~] Modul manajemen: Inventory (supplier, purchase, stok) — API sudah siap
- [ ] Modul manajemen: Branch Management (CRUD branch)
- [ ] Modul: Pengaturan `AppConfig`
- [ ] Modul: Audit Log & Activity Log viewer

## Fase 6 — CRM & User APK ✅

- [x] Migration + API: `CustomerAddress`
- [x] Migration + API: `CustomerFavorite`
- [x] Migration + API: `CustomerCart`
- [x] Migration + API: `CustomerNotification`
- [x] Customer auth: login by phone/email + register
- [x] CustomerPoint (Earn/Redeem/Expired) via PointHistory
- [~] Build UI User APK (Flutter) — registrasi, login, lihat menu, pesan, riwayat, profil

## Fase Promosi (Tabel & API ✅)

- [x] Migration + API: `Promotion`, `PromotionItem`
- [x] Module: `backend/src/modules/promotion/` — repository, service, routes
- [x] Permission `CanManagePromotion` sudah ada di seed sejak Fase 1
- [x] Integrasi Promotion ke service pembuatan order (hitung diskon otomatis)

## Fase 7 — Reporting Module ✅

- [x] Laporan penjualan (per cabang, per periode, per kasir) — endpoint `/reports/sales`
- [x] Laporan stok & pergerakan stok — endpoint `/reports/stock`
- [x] Laporan shift & rekonsiliasi kas — endpoint `/reports/shifts`
- [x] Dashboard ringkasan untuk Owner/Manager — endpoint `/reports/dashboard`

## Fase 8 — System Module ✅

- [x] Migration + API: `AuditLog` — sudah dipakai di Order, User, Item, Payment
- [x] Migration + API: `UserActivity` (login/logout, device, IP)
- [x] Integrasi audit & activity log ke core/transaction/master/crm modules
- [x] Review keamanan endpoint (permission check menyeluruh di seluruh route Fastify)
- [x] **Access Token + Refresh Token** — endpoint `/auth/refresh`, `/auth/logout`, TokenExpired & AccountSuspended handling
- [x] Rate limiting (`@fastify/rate-limit`) pada endpoint login (10/min)
- [x] Rotating refresh token (generate new token on each refresh)
- [x] Pagination (limit/offset) di list endpoints audit & activity

---

## 📱 Frontend Tasks

### POS Kasir App (`pos-kasir/`)

| # | Task | Status |
|---|------|--------|
| 1 | Auth: Login screen + JWT interceptor + auto refresh | ✅ |
| 2 | Menu: List categories + items grid + search | ✅ |
| 3 | Menu: Modifier dialog | ✅ |
| 4 | Table: Grid selection + DineIn/TakeAway toggle | ✅ |
| 5 | Order: Create order + cart view + qty control | ✅ |
| 6 | Order: Confirm order + cancel order | ✅ |
| 7 | Payment: Payment screen + process payment | ✅ |
| 8 | History: Past orders list | ✅ |
| 9 | **Integrasi AppConfig** — baca `GET /app-config` saat login, sembunyikan fitur nonaktif | ⬜ |
| 10 | Integrasi item modifier & discount (sub-resource endpoints) | ⬜ |
| 11 | Kitchen display integration | ⬜ |
| 12 | Shift management (open/close shift) | ⬜ |
| 13 | Responsive UI (compact + medium + expanded) | ⬜ |

### BackOffice App (`backoffice/`)

| # | Task | Status |
|---|------|--------|
| 1 | Auth: Login screen + JWT interceptor + auto refresh | ✅ |
| 2 | Dashboard: Stats grid + quick actions | ✅ |
| 3 | **Inventory: CRUD Items** — connect ke `GET/POST/PUT/DELETE /items` | ⬜ |
| 4 | **Inventory: Categories** — connect ke `GET/POST/PUT/DELETE /categories` | ⬜ |
| 5 | **Inventory: Modifiers** — connect ke `/modifiers` | ⬜ |
| 6 | **Inventory: Stock management** — connect ke `/stock` | ⬜ |
| 7 | **Inventory: Suppliers + Purchases** — connect ke `/suppliers`, `/purchases` | ⬜ |
| 8 | **Inventory: Recipes** — connect ke `/recipes` | ⬜ |
| 9 | **Employees: CRUD Users** — connect ke `GET/POST/PUT/DELETE /users` | ⬜ |
| 10 | **Employees: Role & Permission management** — connect ke `/roles`, `/permissions` | ⬜ |
| 11 | **Branch Management: CRUD Branch** — screen baru, connect ke `/branches` | ⬜ |
| 12 | **Orders: List + filter + confirm/complete/cancel** — connect ke `/orders` | ⬜ |
| 13 | **Reports: Sales report screen** — connect ke `/reports/sales` | ⬜ |
| 14 | **Reports: Stock report screen** — connect ke `/reports/stock` | ⬜ |
| 15 | **Reports: Shift report screen** — connect ke `/reports/shifts` | ⬜ |
| 16 | **Settings: AppConfig** — connect ke `GET/PUT /app-config` | ⬜ |
| 17 | **System: Audit Log viewer** — connect ke `/audit-logs` | ⬜ |
| 18 | Responsive UI (compact + medium + expanded) | ⬜ |

### Dashboard Admin App (`dashboard-admin/`)

| # | Task | Status |
|---|------|--------|
| 1 | Auth: Login screen + JWT interceptor | 🟡 |
| 2 | Overview: Lintas cabang ringkasan — connect ke `/reports/dashboard` | 🟡 |
| 3 | Branches: Perbandingan performa antar cabang | 🟡 |
| 4 | Reports: Sales comparison screen | 🟡 |
| 5 | Reports: Branch performance screen | 🟡 |
| 6 | Audit: Audit Log viewer lintas cabang | 🟡 |
| 7 | Responsive UI | 🟡 |

### User APK App (`user-apk/`)

| # | Task | Status |
|---|------|--------|
| 1 | Auth: Login/Register screen — connect ke `POST /auth/customer/login`, `/register` | 🟡 |
| 2 | Menu: Browse categories + items | 🟡 |
| 3 | Cart: Add to cart + qty control | 🟡 |
| 4 | Orders: Create order + history + tracking | 🟡 |
| 5 | Profile: View/edit profile + addresses | 🟡 |
| 6 | Favorites: Toggle favorites | 🟡 |
| 7 | Points: View point history + redeem | 🟡 |
| 8 | Notifications: List + mark read | 🟡 |

---

## Fase 9 — QA & Hardening

- [ ] Uji multi-branch (data terisolasi per `BranchID`, kecuali akses Owner)
- [ ] Uji skenario permission per role (Cashier, Manager, Owner, Kitchen, Customer)
- [ ] Uji feature flag `AppConfig` — pastikan UI menyesuaikan tanpa perlu deploy ulang
- [ ] Load testing API Fastify untuk skenario banyak cabang/transaksi bersamaan
- [ ] Audit keamanan (SQL injection, auth bypass, rate limiting)
- [ ] Review seluruh migration Knex bisa dijalankan dari kosong (`migrate:latest`) dan di-rollback (`migrate:rollback`) tanpa error

## Fase 10 — Rencana Lanjutan (Opsional)

- [ ] Kitchen Display App terpisah
- [ ] Self Ordering Kiosk
- [ ] Integrasi payment gateway pihak ketiga

---

## Catatan Migration (Knex.js)

- Semua perubahan skema **wajib** lewat file migration (`knex migrate:make nama_migration`), **tidak boleh** mengubah tabel langsung di SQL Server management tool.
- Satu migration idealnya untuk satu tabel atau satu perubahan logis, agar mudah di-rollback.
- Setiap migration harus punya fungsi `up` dan `down` yang benar-benar reversible.
- Urutan migration mengikuti urutan modul di atas (Core → Master → Transaction → Inventory → CRM → Reporting → System) karena ada foreign key antar tabel (mis. `Order` butuh `MstCustomer` dan `Branch` sudah ada duluan).
- Gunakan `seeds/` Knex untuk data awal (role & permission default, `AppConfig` default) agar environment baru bisa langsung dipakai setelah `migrate:latest && seed:run`.

## Catatan Prioritas

Urutan yang disarankan: **Fase 0–3 (Setup, Core, Master, POS Kasir)** terlebih dahulu agar transaksi dasar berjalan, baru dilanjutkan **Fase 4–6 (Inventory, BackOffice, User APK)**, dan terakhir **Fase 7–9 (Reporting, System, QA)** sebelum go-live.

## Audit Log (Fixes from Comprehensive Check)

**Fase 0-5 Audit — 4 bugs fixed & 1 missing code added:**

| # | Issue | File | Fix |
|---|-------|------|-----|
| 1 | CRM `findCustomerById` missing | `crm/repository.js` | Added method (was relied on master repo) |
| 2 | Wrong column `CustomerName` → `FullName` | `crm/service.js` | Register used wrong field name |
| 3 | Wrong column `CustomerName` → `FullName` | `crm/routes.js` | UpdateProfile used wrong field name |
| 4 | `@fastify/auth` unused | `package.json` | Removed dependency |
| 5 | `index.js` never calls `app.listen()` | `src/index.js` | Added server startup with PORT from env |
| 6 | Missing `PUT /orders/:id` | `transaction/routes.js` | Added route for general order updates |

**Runtime verification:** Backend starts, 13 endpoint tests passed (public access, auth guards, customer register/login/profile, address/favorite/cart/notification CRUD).

**Latest cross-check:**
- Backend migrations present through `08_create_refresh_token_table`.
- Master/Core/Transaction/Inventory/Promotion/System route guard audit passed; only `GET /app-config` remains public intentionally.
- Access token + refresh token flow verified: login returns both tokens, refresh creates new access token, logout revokes refresh token.
- `TokenExpired`, `RefreshTokenInvalid`, and `AccountSuspended` responses defined for frontend modal handling.
- Frontend `lib/` template exists across 4 apps with `core/`, `features/`, `models/`, and `routes/` baseline structure.