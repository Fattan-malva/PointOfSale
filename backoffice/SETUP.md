# SETUP — BackOffice

## Prasyarat

- Flutter SDK >= 3.11
- Dart SDK >= 3.11
- Backend POS berjalan di `http://localhost:3000`

## 1. Install Dependencies

```bash
flutter pub get
```

## 2. Konfigurasi

API endpoint sudah diatur di `lib/core/network/api_config.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

## 3. Run

```bash
# Web
flutter run -d chrome
```

Atau build production:
```bash
flutter build web
```

## Test Users

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | admin123 |
| Owner | owner | admin123 |
| Manager | manager | admin123 |
| Cashier | kasir | admin123 |

## Features

- **Dashboard** — Overview dengan statistik (Total Orders, Revenue, Items, Employees)
- **Inventory** — Manajemen item (list, search, add, edit)
- **Employees** — Manajemen karyawan (list, add, filter by role)
- **Orders** — Daftar order dengan filter status (All, Pending, Confirmed, Completed)
- **Reports** — Jenis laporan (Daily, Monthly, Inventory, Employee, Revenue)

## Platform

Didukung: Web, Android, iOS, Windows, macOS, Linux

flutter pub get
```

## 2. Konfigurasi

Sesuaikan `lib/config/api_config.dart` (buat jika belum ada) dengan URL backend:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
}
```

## 3. Menjalankan

```bash
# Web (platform utama)
flutter run -d chrome

# Desktop
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

## Platform

Didukung: Android, iOS, Web, Windows, macOS, Linux

> Catatan: Aplikasi ini masih dalam tahap pengembangan. Setelah backend dan API selesai, integrasikan endpoint API sesuai modul yang dibutuhkan.

## Struktur Folder

```
backoffice/
├── lib/
│   ├── main.dart           # Entry point
│   ├── theme/
│   │   ├── app_theme.dart  # Tema Flutter (DESIGN.md)
│   │   └── app_colors.dart # Token warna
│   └── ...                 # (soon) screens, widgets, services
├── pubspec.yaml
└── ...
```
