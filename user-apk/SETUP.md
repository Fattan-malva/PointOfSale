# SETUP — User APK

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
# Mobile (platform utama)
flutter run

# Web
flutter run -d chrome
```

## Platform

Didukung: Android, iOS, Web, Windows, macOS, Linux

> Catatan: Aplikasi ini masih dalam tahap pengembangan. Setelah backend dan API selesai, integrasikan endpoint API sesuai modul yang dibutuhkan.

## Struktur Folder

```
user-apk/
├── lib/
│   ├── main.dart           # Entry point
│   ├── theme/
│   │   ├── app_theme.dart  # Tema Flutter (DESIGN.md)
│   │   └── app_colors.dart # Token warna
│   └── ...                 # (soon) screens, widgets, services
├── pubspec.yaml
└── ...
```
