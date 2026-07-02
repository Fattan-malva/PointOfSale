# PRD — Sistem POS Multi-Aplikasi (POS Kasir, BackOffice, User APK)

## 1. Latar Belakang

Sistem ini dirancang sebagai **satu database terpusat** yang menjadi pusat seluruh ekosistem, bukan database yang dibuat khusus untuk satu aplikasi POS. Tiga aplikasi utama (dan aplikasi tambahan di masa depan) hanya berperan sebagai **client** yang mengakses data melalui REST API/GraphQL, tanpa menyimpan logika bisnis masing-masing dan tanpa pernah mengakses database secara langsung.

## 2. Tujuan Produk

- Menyediakan satu sumber data (single source of truth) untuk seluruh aplikasi: kasir, manajemen backoffice, dan aplikasi pelanggan.
- Memungkinkan penambahan aplikasi baru (Kitchen Display, Self Ordering Kiosk, Owner Dashboard, dll.) tanpa perubahan besar pada struktur database.
- Mendukung multi-cabang (multi-branch) dari awal.
- Fitur dapat diaktifkan/dinonaktifkan secara dinamis per instalasi/tenant melalui `AppConfig`, tanpa perlu deploy ulang.

## 3. Ruang Lingkup Aplikasi

| Aplikasi | Platform | Peran |
|---|---|---|
| POS Kasir | Flutter (mobile/desktop) | Transaksi penjualan, pembayaran, kirim order ke dapur |
| BackOffice | Flutter Web | Manajemen master data, laporan, konfigurasi, karyawan |
| User APK | Flutter (mobile) | Aplikasi pelanggan: pesan, lihat menu, riwayat, poin, voucher |
| Dashboard/Admin | Flutter (Web) | Monitoring lintas cabang untuk owner |

Semua aplikasi mengakses backend yang sama melalui REST API. Tidak ada aplikasi yang boleh terkoneksi langsung ke SQL Server.

## 4. Target Pengguna

- **Owner** — melihat seluruh data, laporan, dan audit log lintas cabang.
- **Manager** — mengelola operasional cabang, karyawan, dan stok.
- **Cashier** — membuat dan memproses transaksi.
- **Kitchen** — menerima dan memperbarui status order (KDS).
- **Customer** — memesan, melihat riwayat, mengelola profil melalui User APK.

## 5. Modul Fungsional

1. **Core Module** — autentikasi, user, role, permission, cabang, konfigurasi aplikasi.
2. **Master Module** — menu, kategori, modifier, paket, pajak, diskon, metode pembayaran, meja, pelanggan.
3. **Transaction Module** — order, detail order, modifier order, pembayaran, status dapur (KDS), histori meja, shift.
4. **Inventory Module** — supplier, pembelian, stok, pergerakan stok, resep, penggunaan bahan.
5. **CRM Module** — member, poin, voucher, favorit, alamat, notifikasi pelanggan.
6. **Reporting Module** — laporan penjualan, stok, kasir, shift, dashboard.
7. **System Module** — audit log, activity log, media, pengaturan (`AppConfig`).

## 6. Kebutuhan Fungsional Utama

### 6.1 Hak Akses (RBAC)
- Role dan permission tidak boleh di-hardcode; harus dinamis melalui tabel `MstRole`, `MstPermission`, dan `RolePermission`.
- Contoh: Cashier dapat membuat & membayar transaksi tetapi tidak dapat melihat laba atau mengubah harga; Owner memiliki akses penuh; Customer hanya dapat memesan, melihat riwayat, dan mengedit profil.

### 6.2 Pemisahan Data User dan Customer
- `MstUser` khusus untuk pegawai internal (kasir, manager, owner, kitchen).
- `MstCustomer` khusus untuk pelanggan, memiliki atribut tambahan seperti poin, voucher, alamat, menu favorit, device token, dan login sosial (Google/Apple) yang tidak relevan untuk pegawai.

### 6.3 Promosi
- Promosi tidak ditempel langsung ke tabel Order, melainkan melalui entitas `Promotion` dan `PromotionItem` yang generik agar mendukung berbagai tipe: Buy 1 Get 1, Happy Hour, Diskon Menu, Cashback, Member Only, Weekend Promo — semua memakai struktur tabel yang sama.

### 6.4 Media
- Gambar tidak disimpan langsung pada tabel `Item`, melainkan melalui `Media` dan `ItemMedia`, sehingga satu menu dapat memiliki banyak gambar dengan urutan tampil (`SortOrder`).

### 6.5 Audit & Aktivitas
- Setiap perubahan data penting (mis. kasir mengubah transaksi) harus tercatat di `AuditLog` agar dapat ditinjau oleh Owner.
- Setiap login/logout dan aktivitas perangkat dicatat di `UserActivity`.

### 6.6 Konfigurasi Dinamis (AppConfig)
- Fitur seperti Kitchen, Inventory, Customer App, QR Ordering, Voucher, Diskon, Pajak, Service Charge, Split Bill, Reservasi, Delivery, Loyalty, Membership, Multi-Branch, Printer Bluetooth, Kitchen Printer, dan Cash Drawer dapat diaktifkan/nonaktifkan per instalasi.
- Setiap aplikasi membaca konfigurasi ini saat login dan hanya menampilkan fitur yang aktif.

## 7. Kebutuhan Non-Fungsional

- **Keamanan**: seluruh akses data wajib melalui API dengan autentikasi & otorisasi berbasis role/permission.
- **Skalabilitas**: struktur database harus mendukung penambahan aplikasi baru tanpa restrukturisasi besar.
- **Multi-branch**: seluruh entitas transaksional harus dapat difilter/dipisah berdasarkan `BranchID`.
- **Auditabilitas**: seluruh perubahan data kritikal harus tercatat dan dapat ditelusuri.
- **Konsistensi**: tidak ada duplikasi data maupun logika bisnis antar aplikasi.

## 8. Di Luar Ruang Lingkup (Saat Ini)

- Integrasi pembayaran pihak ketiga spesifik (akan didefinisikan terpisah di `PaymentMethod`).
- Aplikasi Kitchen Display dan Self Ordering Kiosk terpisah (direncanakan sebagai pengembangan lanjutan, struktur DB sudah mendukung).

## 9. Kriteria Sukses

- Ketiga aplikasi dapat berjalan menggunakan satu backend/database yang sama tanpa duplikasi logika.
- Penambahan fitur atau aplikasi baru tidak memerlukan perubahan skema database yang signifikan.
- Semua transaksi dan perubahan data kritikal dapat diaudit.