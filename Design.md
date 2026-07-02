# DESIGN.md — Design System

Berlaku untuk ketiga aplikasi Flutter: **POS Kasir**, **BackOffice**, **User APK**. Semua aplikasi wajib memakai token dan aturan yang sama di dokumen ini agar terasa satu ekosistem, meskipun tampilan tiap aplikasi disesuaikan dengan konteks penggunaannya (kasir = cepat & touch-friendly, BackOffice = padat data, User APK = ramah konsumen).

---

## 1. Arah Desain

**Gaya:** Soft UI / Rounded UI — permukaan lembut, sudut membulat, bayangan halus (soft shadow), tanpa garis tegas/hairline yang keras. Hindari gaya *neumorphism* penuh (yang membuat kontras terlalu rendah dan sulit diakses) — ambil bagian "lembut & membulat"-nya saja, bukan efek timbul-tenggelam yang mengorbankan keterbacaan.

**Palet:** Black & white sebagai basis, **namun bukan monokrom**. Artinya:
- Latar, permukaan (surface), dan teks tetap didominasi hitam–putih–abu-abu netral.
- **Satu warna aksen** dipakai secara konsisten dan disiplin untuk elemen yang butuh perhatian: aksi utama (primary button), status aktif, indikator penting, dan grafik/chart.
- Warna semantik (sukses, warning, error) tetap ada secara terpisah dari aksen brand — jangan pakai warna aksen brand untuk error.

**Prinsip:** Minimalis. Ruang kosong (whitespace) adalah bagian dari desain, bukan sisa. Setiap warna, bayangan, dan radius yang dipakai harus punya alasan fungsional (menunjukkan hierarki, status, atau interaktivitas) — bukan dekorasi.

---

## 2. Design Tokens — Warna

### 2.1 Netral (basis Black & White)

| Token | Hex | Pemakaian |
|---|---|---|
| `color.bg` | `#FFFFFF` | Latar utama (light mode) |
| `color.surface` | `#F7F7F8` | Permukaan card/panel di atas `bg` |
| `color.surface-raised` | `#FFFFFF` | Card yang perlu menonjol dari `surface`, dibedakan lewat shadow, bukan warna |
| `color.border` | `#E7E7EA` | Border halus, dipakai tipis dan jarang |
| `color.text-primary` | `#111113` | Teks utama (hampir hitam, bukan `#000000` murni agar tidak terlalu keras) |
| `color.text-secondary` | `#5C5C63` | Teks sekunder/caption |
| `color.text-disabled` | `#A8A8AE` | Teks/ikon nonaktif |
| `color.inverse-bg` | `#111113` | Latar gelap (dipakai terbatas: bottom sheet penting, badge, dark section) |
| `color.inverse-text` | `#FFFFFF` | Teks di atas `inverse-bg` |

### 2.2 Aksen (satu warna, dipakai disiplin)

| Token | Hex | Pemakaian |
|---|---|---|
| `color.accent` | `#2F6FED` (biru indigo lembut) | Primary button, link aktif, tab aktif, focus ring, highlight chart utama |
| `color.accent-soft` | `#EAF0FE` | Latar untuk elemen aksen versi lembut (mis. chip terpilih, background icon aktif) |
| `color.accent-pressed` | `#2456C4` | State pressed/hover dari `accent` |

> Aksen ini bisa disesuaikan per instalasi/tenant jika suatu saat dibutuhkan white-labeling, tetapi **jangan menambah aksen kedua** — satu warna aksen adalah aturan, bukan sementara.

### 2.3 Semantik

| Token | Hex | Pemakaian |
|---|---|---|
| `color.success` | `#1E9E5A` | Transaksi sukses, stok tersedia |
| `color.success-soft` | `#E7F7EE` | Background badge sukses |
| `color.warning` | `#C77700` | Stok menipis, shift belum ditutup |
| `color.warning-soft` | `#FDF1DF` | Background badge warning |
| `color.error` | `#D6314B` | Gagal bayar, refund, validasi error |
| `color.error-soft` | `#FBE7EA` | Background badge error |

### 2.4 Dark Mode (opsional, disiapkan strukturnya)

Gunakan mapping token yang sama, hanya nilai yang dibalik (`bg` → `#111113`, `text-primary` → `#F5F5F6`, dst). Karena tema dasarnya sudah black & white, dark mode relatif mudah — jangan buat palet baru, cukup invert token netral dan pertahankan `color.accent` apa adanya (cukup kontras di kedua mode).

---

## 3. Tipografi

- **Font utama:** satu keluarga font sans-serif geometris/humanis yang punya banyak *weight* (mis. Inter, Plus Jakarta Sans, atau Manrope) — dipakai untuk seluruh aplikasi agar konsisten lintas platform Flutter.
- Jangan mencampur lebih dari satu keluarga font. Perbedaan hierarki dicapai lewat *weight* dan ukuran, bukan ganti font.

| Token | Ukuran | Weight | Pemakaian |
|---|---|---|---|
| `type.display` | 28–32sp | Bold (700) | Judul halaman besar (dashboard, total transaksi) |
| `type.title` | 20–22sp | SemiBold (600) | Judul section/card |
| `type.body-lg` | 16sp | Regular (400) | Isi utama, nama menu di POS |
| `type.body` | 14sp | Regular (400) | Teks standar |
| `type.caption` | 12sp | Regular/Medium | Label, timestamp, metadata |
| `type.numeric` | sesuai konteks | SemiBold (600), tabular-nums | Harga, angka, nominal — **wajib** pakai tabular figures agar angka rapi sejajar di tabel/struk |

Line-height minimal 1.4× untuk body text agar tetap nyaman dibaca di layar kecil (POS Kasir handheld) maupun besar (BackOffice desktop).

---

## 4. Radius & Elevasi (Soft UI)

### 4.1 Radius

| Token | Nilai | Pemakaian |
|---|---|---|
| `radius.sm` | 8px | Chip, badge, input kecil |
| `radius.md` | 14px | Button, input field, list item |
| `radius.lg` | 20px | Card, modal, bottom sheet |
| `radius.xl` | 28px | Card hero/highlight (mis. ringkasan total di POS) |
| `radius.pill` | 999px | Tombol pill, tag status |

Konsisten membulat — hindari mencampur sudut tajam dan sudut membulat dalam satu grup komponen yang sama.

### 4.2 Bayangan (Soft Shadow)

Gunakan bayangan lembut, difus, dengan opacity rendah — bukan bayangan tajam/hitam pekat.

| Token | Spesifikasi (kira-kira) | Pemakaian |
|---|---|---|
| `shadow.xs` | `0 1px 2px rgba(17,17,19,0.04)` | Border pengganti pada elemen datar |
| `shadow.sm` | `0 2px 8px rgba(17,17,19,0.06)` | List item, input focus |
| `shadow.md` | `0 6px 16px rgba(17,17,19,0.08)` | Card standar |
| `shadow.lg` | `0 12px 28px rgba(17,17,19,0.10)` | Modal, floating action button, bottom sheet |

Karena tema hitam-putih, kedalaman (depth) dibangun lewat kombinasi **shadow + radius + sedikit perbedaan `surface`**, bukan lewat warna gelap yang berat.

---

## 5. Spacing & Grid

Skala spacing 4px (multiples of 4) agar konsisten di semua breakpoint:

```
space.1 = 4px   space.2 = 8px   space.3 = 12px  space.4 = 16px
space.5 = 20px  space.6 = 24px  space.8 = 32px  space.10 = 40px
space.12 = 48px space.16 = 64px
```

- Padding default card/panel: `space.4`–`space.6`.
- Jarak antar elemen dalam list: minimal `space.2`.
- Jarak antar section: minimal `space.8`.

---

## 6. Komponen — Prinsip Umum

- **Button:** radius `md`–`pill`, padding vertikal cukup besar untuk touch target (lihat §8), primary button pakai `color.accent`, secondary pakai outline netral (`color.border`) dengan teks `color.text-primary`, tanpa fill warna.
- **Input field:** radius `md`, latar `color.surface`, tanpa border tebal — cukup `shadow.xs` atau border 1px `color.border`; saat fokus, border/ring pakai `color.accent`.
- **Card:** radius `lg`, latar `color.surface-raised`, `shadow.sm`–`shadow.md`. Hindari border ganda (jangan pakai border DAN shadow tebal sekaligus — pilih salah satu sebagai pemisah utama).
- **Badge/status chip:** radius `pill`, latar versi `-soft` dari warna semantik terkait, teks warna solidnya (mis. background `success-soft`, teks `success`).
- **Bottom navigation (mobile)**: ikon + label, item aktif memakai `color.accent` dan latar `accent-soft` berbentuk pill di belakang ikon.
- **Empty state & error state:** ilustrasi/ikon sederhana garis (line icon, bukan foto/ilustrasi ramai), judul singkat, satu call-to-action jelas — konsisten di ketiga aplikasi.

---

## 7. WAJIB: Responsive UI Cross-Platform

Ketiga aplikasi Flutter (mobile, tablet, web, desktop) **wajib** responsif. Ini bukan opsional/nice-to-have — semua layar harus lolos aturan berikut sebelum dianggap selesai.

### 7.1 Breakpoint Standar

| Breakpoint | Lebar | Konteks |
|---|---|---|
| `compact` | < 600dp | HP (POS Kasir handheld, User APK) |
| `medium` | 600–1023dp | Tablet, POS Kasir di tablet kasir |
| `expanded` | 1024–1439dp | BackOffice di laptop, tablet landscape besar |
| `large` | ≥ 1440dp | BackOffice/Dashboard di monitor desktop |

Gunakan `LayoutBuilder` / `MediaQuery` di Flutter untuk menentukan breakpoint secara terpusat (satu helper `AppBreakpoints`, jangan hardcode angka di banyak tempat).

### 7.2 Aturan Wajib per Breakpoint

- **`compact`**: layout satu kolom, navigasi utama di bottom navigation bar, konten memenuhi lebar layar dengan padding horizontal `space.4`.
- **`medium`**: mulai gunakan layout dua kolom untuk list+detail (mis. daftar order di kiri, detail order di kanan) jika konten memungkinkan; navigasi bisa tetap bottom nav atau rail tergantung app.
- **`expanded`/`large`` (utamanya BackOffice)**: gunakan **navigation rail/side navigation**, bukan bottom navigation. Layout multi-kolom (list, detail, aksi) dan tabel data penuh tanpa horizontal scroll yang tidak perlu.
- **Tidak boleh ada ukuran piksel yang di-hardcode** untuk lebar container utama — semua lebar relatif terhadap layar (`MediaQuery.of(context).size`, `Flexible`, `Expanded`, `FractionallySizedBox`) atau dibatasi dengan `maxWidth` yang masuk akal (mis. form di desktop dibatasi `maxWidth: 480` agar tidak melebar penuh layar, tapi tetap dibungkus layout yang fleksibel).

### 7.3 Orientasi & Perangkat

- Semua layar POS Kasir dan User APK harus tetap dapat dipakai di **portrait maupun landscape** (kasir sering pakai tablet landscape).
- Uji minimal di 3 kelas perangkat: HP kecil (~360dp), tablet (~768dp), desktop/web (~1440dp).
- BackOffice sebagai Flutter Web harus tetap dapat diakses dan tetap fungsional di lebar browser sekecil layar tablet (tidak harus indah, tapi tidak boleh rusak/terpotong).

### 7.4 Touch Target & Aksesibilitas

- Minimal ukuran target sentuh: **44×44dp** (idealnya 48×48dp untuk aksi utama POS Kasir yang dipakai berulang, mis. tombol tambah item).
- Kontras teks terhadap latar minimal memenuhi WCAG AA (rasio ≥ 4.5:1 untuk teks normal) — karena basis warna hitam-putih, ini seharusnya mudah dicapai selama tidak memakai abu-abu yang terlalu terang di atas putih.
- Semua komponen interaktif (button, input, tab) harus punya state visual yang jelas: default, hover (untuk web/desktop), pressed, focus (visible focus ring, terutama penting untuk BackOffice yang dipakai dengan keyboard), dan disabled.
- Teks harus tetap terbaca saat pengguna membesarkan ukuran font sistem (dukung `textScaleFactor`), jangan gunakan `Text` dengan tinggi container yang fixed sehingga teks terpotong.

### 7.5 Checklist Responsive (wajib dicek sebelum sebuah layar dianggap "selesai")

- [ ] Layar diuji di breakpoint `compact`, `medium`, dan `expanded`/`large` tanpa elemen terpotong/overflow.
- [ ] Tidak ada `width`/`height` piksel tetap untuk container level halaman.
- [ ] Navigasi berubah sesuai breakpoint (bottom nav ↔ rail/side nav) bila app tersebut memang butuh (BackOffice wajib; POS Kasir & User APK minimal tidak rusak di breakpoint besar).
- [ ] Semua tombol/ikon interaktif ≥ 44×44dp.
- [ ] Kontras warna teks vs latar lolos AA.
- [ ] Diuji di orientasi portrait & landscape (khusus POS Kasir & User APK).
- [ ] Diuji dengan `textScaleFactor` diperbesar (mis. 1.3×) tanpa teks terpotong.

---

## 8. Panduan Khusus per Aplikasi

### POS Kasir
- Prioritas: kecepatan input, target sentuh besar, minim scroll untuk aksi yang sering dipakai (tambah item, bayar).
- Grid menu (`Category`/`Item`) menyesuaikan jumlah kolom berdasarkan breakpoint: 2 kolom di `compact`, 3–4 kolom di `medium`/`expanded`.
- Ringkasan order (cart) sebaiknya selalu terlihat: panel bawah di `compact`, panel samping tetap terlihat (persistent) di `medium` ke atas.

### BackOffice
- Prioritas: kepadatan data yang tetap mudah dibaca. Tabel harus responsif — di layar sempit, tabel bisa berubah jadi list card per baris, bukan dipaksa horizontal-scroll terus-menerus.
- Gunakan navigation rail di `expanded`/`large`, drawer/bottom nav sederhana di `compact` (BackOffice tetap harus bisa dibuka darurat dari HP meski pengalaman utamanya di desktop).

### User APK
- Prioritas: nyaman dilihat konsumen, ramah non-teknis. Gunakan lebih banyak whitespace dan card besar (radius `lg`/`xl`) dibanding BackOffice yang lebih padat.
- Gambar menu (`Media`/`ItemMedia`) selalu ditampilkan dengan rasio aspek konsisten (mis. 1:1 atau 4:3) dan radius `lg`, jangan biarkan gambar dengan rasio berbeda merusak grid.

---

## 9. Yang Harus Dihindari

- Jangan menambah warna aksen kedua/ketiga di luar yang didefinisikan — godaan untuk "menghidupkan" tampilan harus disalurkan lewat tipografi, spacing, dan ilustrasi garis minimalis, bukan warna baru.
- Jangan memakai bayangan tajam/hitam pekat (`box-shadow` gelap dengan opacity tinggi) — bertentangan dengan prinsip Soft UI.
- Jangan hardcode lebar/tinggi piksel untuk layout level halaman.
- Jangan memakai warna aksen brand (`color.accent`) untuk pesan error — pakai `color.error`.
- Jangan membuat lebih dari satu keluarga font dalam satu aplikasi.

---

## 10. Template Folder Struktur Flutter

Struktur folder ini **wajib sama** di semua 4 aplikasi: `pos-kasir/`, `backoffice/`, `user-apk/`, `dashboard-admin/`. Tujuannya: maintainability, consistency, dan onboarding developer yang cepat.

### 10.1 Struktur Folder Utama

```
lib/
├── main.dart                         # App entry point
├── app.dart                          # MaterialApp / CupertinoApp wrapper
│
├── core/                             # Shared utilities (ALL apps use this)
│   ├── constants/
│   │   ├── app_colors.dart           # Design token: warna
│   │   ├── app_typography.dart       # Design token: typografi
│   │   ├── app_spacing.dart          # Design token: spacing & radius
│   │   └── app_shadows.dart          # Design token: shadow
│   ├── theme/
│   │   ├── app_theme.dart            # ThemeData builder (light mode)
│   │   └── theme_extensions.dart     # Custom theme extensions
│   ├── network/
│   │   ├── api_client.dart           # Dio/DioClient singleton
│   │   ├── api_config.dart           # Base URL, timeouts
│   │   ├── auth_interceptor.dart     # Attach token ke setiap request
│   │   └── error_mapper.dart         # Map HTTP error ke user-friendly message
│   ├── storage/
│   │   ├── storage_keys.dart         # constants untuk SecureStorage keys
│   │   └── secure_storage.dart        # baca/tulis token, user data
│   ├── utils/
│   │   ├── currency_formatter.dart   # format mata uang IDR
│   │   ├── date_formatter.dart       # format tanggal
│   │   ├── validators.dart           # input validation
│   │   └── responsive.dart           # breakpoint helper (AppBreakpoints)
│   └── widgets/
│       ├── app_button.dart           # reusable button (primary, secondary, etc)
│       ├── app_card.dart             # base card dengan soft shadow
│       ├── app_text_field.dart       # base input field
│       ├── loading_overlay.dart       # full-screen loading
│       ├── error_view.dart           # error state UI
│       ├── empty_view.dart           # empty state UI
│       ├── status_badge.dart         # badge/chip dengan semantic colors
│       └── responsive_layout.dart    # LayoutBuilder wrapper
│
├── features/                         # Feature-based modules
│   ├── auth/
│   │   ├── auth_provider.dart        # ChangeNotifier/StateNotifier
│   │   ├── login_screen.dart
│   │   ├── logout_dialog.dart        # logout confirmation
│   │   └── token_expiry_dialog.dart  # modal: "Session expired"
│   │
│   ├── home/
│   │   ├── home_provider.dart
│   │   └── home_screen.dart
│   │
│   ├── profile/
│   │   ├── profile_provider.dart
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   │
│   └── [fitur spesifik app]/
│       │
│       ├── xxx_provider.dart         # State management per fitur
│       ├── xxx_screen.dart            # 1 screen = 1 file
│       ├── xxx_detail_screen.dart
│       ├── widgets/
│       │   ├── xxx_card.dart          # komponen lokal fitur
│       │   └── xxx_list_tile.dart
│       ├── models/
│       │   └── xxx_model.dart         # 1 model = 1 file
│       └── repositories/
│           └── xxx_repository.dart   # data layer akses API
│
├── models/                           # Shared domain models (cross-feature)
│   ├── user_model.dart
│   ├── branch_model.dart
│   ├── item_model.dart
│   └── [model yang dipakai di banyak fitur]
│
└── routes/
    ├── app_router.dart               # GoRouter/Riverpod Router setup
    └── route_names.dart              # named route constants
```

### 10.2 Prinsip Organisasi

| Prinsip | Penjelasan |
|---|---|
| **Feature-first** | Organisasi berdasarkan *fitur*, bukan tipe file. `features/auth/` berisi semua yang berhubungan dengan auth. |
| **1 file = 1 class** | `item_card.dart` = 1 widget. `item_model.dart` = 1 model. Tidak ada `items.dart` yang export 10 hal. |
| **Core sebagai shared** | `core/` adalah kode yang dipakai semua app. Tidak boleh ada kode spesifik app di `core/`. |
| **Models di shared** | Model/domain objects yang dipakai di banyak fitur ada di `models/`, bukan di `features/xxx/models/`. |

### 10.3 File Per App (specific files)

Tambahkan file ini di root `lib/` sesuai kebutuhan app:

**POS Kasir** (`pos-kasir/`):
```
pos-kasir/lib/
├── main.dart                         # entry point
├── app.dart                          # MaterialApp dengan POS Kasir theme
├── core/
│   └── widgets/
│       ├── pos_keypad.dart           # numpad untuk quantity
│       └── order_summary_panel.dart # panel cart di samping
└── features/
    ├── pos/
    │   ├── pos_screen.dart           # layar utama POS
    │   ├── pos_provider.dart         # state: currentOrder, cart items
    │   └── widgets/
    │       ├── category_grid.dart    # grid kategori
    │       ├── item_grid.dart        # grid item dengan harga
    │       ├── cart_item_tile.dart   # item di cart
    │       └── payment_dialog.dart    # dialog pembayaran
    ├── orders/
    │   ├── order_history_screen.dart
    │   └── order_detail_screen.dart
    └── kitchen/
        ├── kitchen_screen.dart       # KDS view
        └── kitchen_provider.dart
```

**BackOffice** (`backoffice/`):
```
backoffice/lib/
├── main.dart
├── app.dart                          # MaterialApp dengan BackOffice theme
└── features/
    ├── dashboard/
    │   └── dashboard_screen.dart      # ringkasan harian/mingguan
    ├── master/
    │   ├── categories/
    │   ├── items/
    │   ├── modifiers/
    │   └── tables/
    ├── employees/
    │   ├── employee_list_screen.dart
    │   └── employee_form_screen.dart
    ├── inventory/
    │   ├── stock_screen.dart
    │   └── purchase_screen.dart
    └── reports/
        ├── sales_report_screen.dart
        └── shift_report_screen.dart
```

**User APK** (`user-apk/`):
```
user-apk/lib/
├── main.dart
├── app.dart                          # MaterialApp dengan User APK theme
└── features/
    ├── menu/                         # browse menu
    ├── cart/                         # keranjang
    ├── orders/
    │   ├── order_history_screen.dart
    │   └── order_tracking_screen.dart
    ├── favorites/
    └── addresses/
```

**Dashboard Admin** (`dashboard-admin/`):
```
dashboard-admin/lib/
├── main.dart
├── app.dart
└── features/
    ├── overview/                     # lintas cabang ringkasan
    ├── branches/                     # manajemen cabang
    ├── reports/
    │   ├── sales_comparison_screen.dart
    │   └── branch_performance_screen.dart
    └── audit/
        └── audit_log_screen.dart
```

### 10.4 Aturan Routing

- Gunakan **GoRouter** (atau package routing yang setara dari state management yang dipakai).
- Named routes dengan konstanta di `routes/route_names.dart`.
- Auth guard di level router: jika `accessToken` null, redirect ke `/login`.
- Route `/home` atau `/pos` (tergantung app) sebagai default setelah login berhasil.
- Route `/login` tidak perlu guard (publik).

### 10.5 State Management

- **Dipilih sendiri** sesuai preferensi tim (Riverpod, Provider, Bloc, GetX, dsb).
- Jika pakai Riverpod: struktur provider mengikuti folder fitur (`features/xxx/xxx_provider.dart`).
- Repository pattern untuk akses data: `features/xxx/repositories/xxx_repository.dart` menghandle semua API calls.
- **Tidak boleh** ada `Provider` atau `ChangeNotifier` yang berisi kode yang mengakses API langsung di dalam widget. Selalu lewat repository.

### 10.6 API Client Setup (core/network/)

```dart
// api_client.dart
class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static Dio get instance {
    _dio.interceptors.add(AuthInterceptor(SecureStorage.instance));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));
    return _dio;
  }
}

// auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final errMsg = err.response?.data['error'];
      if (errMsg == 'TokenExpired') {
        // Coba refresh token
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry original request
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${await _storage.getAccessToken()}';
          final r = await _dio.fetch(opts);
          return handler.resolve(r);
        }
      }
      // Token invalid / refresh gagal / AccountSuspended
      // Hapus token dan navigasi ke login
      await _storage.clearTokens();
      // Navigate to login screen
      AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.login);
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;
      final r = await Dio().post(
        '${ApiConfig.baseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      if (r.statusCode == 200 && r.data['accessToken'] != null) {
        await _storage.saveAccessToken(r.data['accessToken']);
        return true;
      }
    } catch (e) {}
    return false;
  }
}
```

### 10.7 Assets

```
assets/
├── images/
│   ├── logo.png
│   ├── empty_state.svg
│   └── error_state.svg
└── icons/
    └── app_icon.svg
```

### 10.8 Checklist Sebelum Buat File Baru

- [ ] Apakah kode ini bisa dipakai di lebih dari satu app? → taruh di `core/`
- [ ] Apakah kode ini milik satu fitur spesifik? → taruh di `features/xxx/`
- [ ] Apakah ini 1 widget reusable yang berdiri sendiri? → `core/widgets/`
- [ ] Apakah ini 1 model/domain object? → `models/` atau `features/xxx/models/`
- [ ] Apakah nama file sudah deskriptif dan dalam `snake_case`? (bukan `util.dart`, tapi `currency_formatter.dart`)