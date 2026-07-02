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
- [ ] Build UI POS Kasir (Flutter) — konsumsi API di atas
- [ ] POS Kasir membaca `GET /app-config` saat login

## Fase 4 — Inventory Module ✅

- [x] Migration + API: `Supplier`
- [x] Migration + API: `Purchase`, `PurchaseDetail`
- [x] Migration + API: `Stock`, `StockMovement`
- [x] Migration + API: `Recipe`, `RecipeDetail`
- [x] Service: logika pengurangan stok otomatis saat order (berdasarkan resep) — aktif jika `EnableInventory`

## Fase 5 — BackOffice App

- [ ] Modul manajemen: Master data (menu, kategori, modifier, dsb.) — API sudah siap
- [ ] Modul manajemen: Karyawan & Role/Permission — API sudah siap
- [ ] Modul manajemen: Promosi & Voucher — butuh Fase Promosi
- [ ] Modul manajemen: Inventory (supplier, purchase, stok) — API sudah siap
- [ ] Modul: Pengaturan `AppConfig` per cabang/tenant — API sudah siap
- [ ] Modul: Audit Log & Activity Log viewer — butuh Fase System Logging

## Fase 6 — CRM & User APK ✅

- [x] Migration + API: `CustomerAddress`
- [x] Migration + API: `CustomerFavorite`
- [x] Migration + API: `CustomerCart`
- [x] Migration + API: `CustomerNotification`
- [x] Customer auth: login by phone/email + register
- [ ] Migration + API: `CustomerPoint` (Earn/Redeem/Expired) — PointHistory sudah ada di Fase 3
- [ ] Build UI User APK (Flutter) — registrasi, login, lihat menu, pesan, riwayat, profil
- [ ] Integrasi QR Ordering — aktif jika `EnableQROrdering`
- [ ] Integrasi Delivery/Reservation — aktif jika `EnableDelivery` / `EnableReservation`

## Fase Promosi (Tabel & API ✅)

- [x] Migration + API: `Promotion`, `PromotionItem`
- [x] Module: `backend/src/modules/promotion/` — repository, service, routes
- [x] Permission `CanManagePromotion` sudah ada di seed sejak Fase 1
- [x] Integrasi Promotion ke service pembuatan order (hitung diskon otomatis)

## Fase 7 — Reporting Module

- [ ] Laporan penjualan (per cabang, per periode, per kasir)
- [ ] Laporan stok & pergerakan stok
- [ ] Laporan shift & rekonsiliasi kas
- [ ] Dashboard ringkasan untuk Owner/Manager

## Fase 8 — System Module

- [x] Migration + API: `AuditLog` — sudah dipakai di Order, User, Item, Payment
- [x] Migration + API: `UserActivity` (login/logout, device, IP)
- [x] Integrasi audit & activity log ke core/transaction/master/crm modules
- [x] Review keamanan endpoint (permission check menyeluruh di seluruh route Fastify)
- [x] **Access Token + Refresh Token** — endpoint `/auth/refresh`, `/auth/logout`, TokenExpired & AccountSuspended handling
- [ ] Rate limiting (`@fastify/rate-limit`) pada endpoint login & sensitif
- [ ] Rotating refresh token (generate new token on each refresh)
- [ ] Blacklist access token saat logout atau password change

## Fase 8.5 — Dashboard/Admin App

- [ ] Modul: Ringkasan lintas cabang (penjualan, stok, shift) untuk Owner
- [ ] Modul: Perbandingan performa antar cabang
- [ ] Modul: Akses cepat ke Audit Log & Activity Log lintas cabang
- [ ] Dashboard/Admin membaca `GET /app-config` dan hanya menampilkan data yang diizinkan sesuai permission Owner/Manager

## Fase 9 — QA & Hardening

- [ ] Uji multi-branch (data terisolasi per `BranchID`, kecuali akses Owner)
- [ ] Uji skenario permission per role (Cashier, Manager, Owner, Kitchen, Customer)
- [ ] Uji feature flag `AppConfig` — pastikan UI menyesuaikan tanpa perlu deploy ulang
- [ ] Load testing API Fastify untuk skenario banyak cabang/transaksi bersamaan
- [ ] Audit keamanan (SQL injection, auth bypass, rate limiting — mis. `@fastify/rate-limit`)
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