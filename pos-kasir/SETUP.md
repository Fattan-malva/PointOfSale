# SETUP — POS Kasir

## Prasyarat

- Flutter SDK >= 3.11
- Dart SDK >= 3.11

## 1. Install Dependencies

```bash
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
# Mobile (Android/iOS)
flutter run

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

## Test Credentials

Berikut username dan password untuk masing‑masing role yang sudah disediakan di seed:

| Role   | Username | Password |
|--------|----------|----------|
| Admin  | admin    | admin123 |
| Owner  | owner    | admin123 |
| Manager| manager  | admin123 |
| Kasir  | kasir    | admin123 |
| Dapur  | dapur    | admin123 |

Gunakan kredensial di atas untuk login pada aplikasi POS Kasir.

## Platform

Didukung: Android, iOS, Web, Windows, macOS, Linux

> Catatan: Aplikasi ini masih dalam tahap pengembangan. Setelah backend dan API selesai, integrasikan endpoint API sesuai modul yang dibutuhkan.

## Struktur Folder

```
pos-kasir/
├── lib/
│   ├── main.dart           # Entry point
│   ├── theme/
│   │   ├── app_theme.dart  # Tema Flutter (DESIGN.md)
│   │   └── app_colors.dart # Token warna
│   └── ...                 # (soon) screens, widgets, services
├── pubspec.yaml
└── ...
```
