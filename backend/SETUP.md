# SETUP — Backend

## Prasyarat

- Node.js >= 18
- SQL Server (local atau remote)
- npm

## 1. Konfigurasi

Salin `.env.example` ke `.env` dan sesuaikan:

```bash
cp .env.example .env
```

Edit `.env`:
```
DB_SERVER=localhost
DB_PORT=1433
DB_USER=sa
DB_PASSWORD=your-password
DB_NAME=pos_db
JWT_SECRET=your-random-secret-key
```

## 2. Install Dependencies

```bash
npm install
```

## 3. Setup Database

```bash
npm run migrate:latest
```

Jalankan seed (data awal role & permission):

```bash
npm run seed:run
```

## 4. Reset Database (Rollback & Re‑migrate)

Jika ingin mengembalikan semua tabel ke kondisi awal (misalnya setelah percobaan atau perubahan schema), ikuti langkah berikut:

1. **Rollback semua migration** – ini akan menghapus semua tabel yang dibuat oleh migration terakhir. Gunakan perintah:
   ```bash
   npm run migrate:rollback -- --all
   ```
   (Opsional: tambahkan `--all` untuk memastikan semua batch migration di‑rollback sekaligus.)

2. **Jalankan kembali semua migration** untuk membuat ulang struktur tabel:
   ```bash
   npm run migrate:latest
   ```

3. **Seed data awal** – setelah tabel dibuat ulang, jalankan seed untuk mengisi data dasar (role, permission, user, dll.)
   ```bash
   npm run seed:run
   ```

> **Catatan:** Pastikan koneksi ke database (`.env`) sudah benar dan tidak ada data penting yang ingin dipertahankan, karena proses rollback akan menghapus semua data.

## 5. Menjalankan Server

```bash
# Development (dengan auto-reload)
npm run dev

# Production
npm start
```

Server berjalan di `http://localhost:3000`.

## 6. Verifikasi

Cek health endpoint:

```bash
curl http://localhost:3000/health
# Response: { "status": "ok", "database": "connected" }
```

## Scripts npm

| Command | Fungsi |
|---|---|
| `npm run migrate:make nama` | Buat file migration baru |
| `npm run migrate:latest` | Jalankan semua pending migration |
| `npm run migrate:rollback` | Rollback batch terakhir |
| `npm run seed:run` | Jalankan seed data |
| `npm run dev` | Jalankan dengan auto-reload |
| `npm start` | Jalankan production |

## Struktur Folder

```
backend/
├── src/
│   ├── app.js              # Fastify app + plugin registrasi
│   ├── index.js            # Barrel export
│   ├── db/
│   │   └── index.js        # Koneksi Knex
│   └── modules/
│       ├── core/           # Branch, Role, Permission, User, Auth, AppConfig
│       ├── master/         # (soon) Category, Item, Modifier, dll
│       ├── transaction/    # (soon) Order, Payment, KDS
│       ├── inventory/      # (soon) Supplier, Stock, Recipe
│       ├── crm/            # (soon) Customer, Point, Voucher
│       ├── reporting/      # (soon) Laporan
│       └── system/         # (soon) AuditLog, ActivityLog
├── migrations/             # File migration Knex
├── seeds/                  # Seed data
├── knexfile.js             # Konfigurasi Knex
├── index.js                # Entry point server
└── package.json
```
