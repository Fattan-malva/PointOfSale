# GUIDELINE.md — Panduan Arsitektur & Pengembangan

## 1. Prinsip Utama

> **Database adalah pusat seluruh ekosistem, bukan database untuk satu aplikasi POS.**

Keempat aplikasi (POS Kasir, BackOffice, User APK, Dashboard/Admin) — dan aplikasi tambahan di masa depan — adalah **client**. Semua akses data **wajib** melalui REST API/GraphQL. **Tidak ada** aplikasi Flutter yang boleh mengakses SQL Server secara langsung.

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
 (Flutter)         (Flutter)          (Flutter)       (Flutter)
```

Alasan: keamanan dan aturan bisnis harus tetap terpusat di backend, bukan tersebar di masing-masing aplikasi client.

## 2. Struktur Folder Proyek

Setiap aplikasi (termasuk backend) disetup di **folder terpisah, sejajar (sibling)**, bukan dicampur dalam satu folder. Total **5 folder** di root workspace/repo:

```text
root/
├── backend/            # Fastify + Knex + SQL Server
├── pos-kasir/           # Flutter — POS Kasir
├── backoffice/          # Flutter — BackOffice
├── user-apk/             # Flutter — User APK (aplikasi pelanggan)
├── dashboard-admin/      # Flutter — Dashboard/Admin (owner, lintas cabang)
│
├── PRD.md
├── TASK.md
├── GUIDELINE.md
├── DATABASE.md
├── DESIGN.md
└── AGENT.md
```

Aturan folder:

- **`backend/`** berisi seluruh source code Fastify: `src/modules/{core,master,transaction,inventory,crm,reporting,system}`, `migrations/`, `seeds/`, `knexfile.js`, dst. Ini satu-satunya folder yang boleh menyentuh database.
- **`pos-kasir/`, `backoffice/`, `user-apk/`, `dashboard-admin/`** masing-masing adalah project Flutter mandiri (`flutter create` terpisah), dengan `pubspec.yaml` sendiri-sendiri. Jangan digabung jadi satu project Flutter dengan flavor/target berbeda — keempatnya harus benar-benar terpisah agar bisa dikembangkan, di-build, dan dirilis secara independen.
- Setiap folder aplikasi Flutter tetap **wajib** mengikuti token desain yang sama dari `DESIGN.md` (lihat juga rencana membuat package/module `design_system` yang di-share, opsional untuk tahap lanjut — lihat §4).
- Dokumen proyek (`PRD.md`, `TASK.md`, `GUIDELINE.md`, `DATABASE.md`, `DESIGN.md`, `AGENT.md`) berada di **root**, di luar kelima folder tersebut, karena berlaku lintas aplikasi.
- Tidak ada folder `.git` terpisah per aplikasi kecuali pengguna eksplisit meminta multi-repo — secara default kelima folder ini berada dalam satu workspace kerja yang sama.

## 3. Aturan Hak Akses (RBAC)

- **Jangan hardcode** permission di kode aplikasi maupun backend.
- Semua kombinasi akses ditentukan lewat tabel `RolePermission`, bukan `if role == "Cashier"` yang tersebar di banyak tempat.
- Setiap endpoint API harus memeriksa permission user berdasarkan role-nya, bukan hanya role secara langsung.
- Tambah role/permission baru = insert data baru, **bukan** deploy ulang kode.

## 4. Pemisahan User vs Customer

- Jangan pernah menyatukan `MstUser` (pegawai) dengan `MstCustomer` (pelanggan) dalam satu tabel, meskipun terlihat mirip di awal.
- Autentikasi pegawai dan autentikasi pelanggan sebaiknya menggunakan endpoint/flow yang berbeda, karena kebutuhan (login sosial, device token, dsb.) berbeda.

## 5. Modularitas Backend

Kembangkan `backend/` per modul agar mudah dipelihara:

1. Core (auth, user, role, permission, branch, config)
2. Master (menu, kategori, modifier, paket, pajak, diskon, meja, customer)
3. Transaction (order, pembayaran, KDS, shift)
4. Inventory (supplier, purchase, stok, resep)
5. CRM (member, poin, voucher, favorit, alamat, notifikasi)
6. Reporting (laporan & dashboard)
7. System (audit log, activity log, media, AppConfig)

Setiap modul idealnya memiliki service/repository sendiri di dalam `backend/src/modules/<modul>/` agar tidak saling tercampur.

## 6. Promosi & Diskon

- Jangan menambahkan kolom diskon langsung di tabel `Order`.
- Semua promosi harus melalui `Promotion` + `PromotionItem` agar tipe promo baru (mis. bundling baru) tidak memerlukan perubahan skema.

## 7. Media/Gambar

- Jangan simpan path gambar langsung di tabel `Item`.
- Gunakan `Media` + `ItemMedia` agar satu item bisa punya banyak gambar dan urutan tampil bisa diatur.

## 8. Audit & Logging

- Setiap operasi yang mengubah data transaksi penting (edit harga, cancel order, refund) **wajib** dicatat ke `AuditLog` dengan `OldValue` dan `NewValue`.
- Setiap login/logout dicatat ke `UserActivity`, termasuk device dan IP address, untuk keperluan keamanan.
- Implementasikan pencatatan ini di level backend/service, bukan di aplikasi client, agar tidak bisa dilewati.

## 9. AppConfig / Feature Flags

- Semua fitur opsional (Kitchen, Inventory, Customer App, QR Ordering, Voucher, dst.) dikontrol lewat `AppConfig`.
- Aplikasi client **wajib** membaca `AppConfig` saat login dan menyembunyikan/menonaktifkan fitur yang tidak aktif — jangan hardcode tampilan fitur di client.
- Ini memungkinkan satu basis kode dipakai untuk berbagai jenis bisnis (restoran, kafe, retail) dengan konfigurasi berbeda.

## 10. Multi-Branch

- Setiap entitas transaksional dan operasional yang relevan harus menyertakan `BranchID`.
- API harus memfilter data berdasarkan cabang sesuai konteks user yang login (kecuali Owner yang bisa melihat lintas cabang).

## 11. Keamanan API

- Autentikasi menggunakan token (misal JWT) untuk `MstUser` dan `MstCustomer` secara terpisah.
- Setiap request harus divalidasi terhadap permission yang relevan sebelum mengeksekusi aksi.
- Data sensitif (harga modal, laba) hanya boleh diakses oleh role yang memiliki permission terkait (`CanViewSales`, dll.).

## 12. Skalabilitas untuk Aplikasi Baru

Struktur database, API, dan folder dirancang agar aplikasi baru (mis. Kitchen Display, Self Ordering Kiosk) dapat ditambahkan **tanpa** mengubah skema atau struktur folder yang ada secara besar-besaran — cukup:
1. Tambahkan folder sibling baru di root (mis. `kitchen-display/`), atau
2. Buat client baru yang mengonsumsi API yang sudah ada, atau
3. Tambahkan endpoint baru di modul `backend/` yang relevan bila diperlukan.

## 13. Checklist Sebelum Menambah Fitur Baru

- [ ] Apakah fitur ini butuh permission baru? → tambahkan ke `MstPermission` + `RolePermission`, jangan hardcode.
- [ ] Apakah fitur ini butuh toggle aktif/nonaktif? → tambahkan ke `AppConfig`.
- [ ] Apakah perubahan data ini perlu diaudit? → catat ke `AuditLog`.
- [ ] Apakah fitur ini spesifik per cabang? → pastikan menyertakan `BranchID`.
- [ ] Apakah logika bisnis ditulis di `backend/` (bukan di folder aplikasi client)?
- [ ] Apakah kode diletakkan di folder yang benar (`backend/`, `pos-kasir/`, `backoffice/`, `user-apk/`, atau `dashboard-admin/`)?