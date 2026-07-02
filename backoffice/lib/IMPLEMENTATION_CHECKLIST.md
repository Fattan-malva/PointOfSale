/// Implementation Checklist - Panduan implementasi selanjutnya

/// PHASE 1 INFRASTRUCTURE - CHECKLIST
/// Semua file sudah dibuat, sekarang tinggal implementasi detail:
///
/// 1. NETWORK LAYER (core/network/)
///    [ ] Implementasi SecureStorage (flutter_secure_storage)
///    [ ] Implementasi ApiClient dengan Dio
///    [ ] Implementasi AuthInterceptor
///    [ ] Implementasi ErrorMapper
///
/// 2. STATE MANAGEMENT (features/auth/)
///    [ ] Setup Riverpod/Provider untuk Auth State
///    [ ] Implementasi AuthProvider/AuthController
///    [ ] Implementasi TokenRefresh logic
///
/// 3. ROUTING (routes/)
///    [ ] Implementasi GoRouter dengan GuardRoute untuk auth
///    [ ] Setup navigation path untuk semua screen
///
/// 4. BASE MODELS (models/)
///    [ ] Tambah model lainnya sesuai kebutuhan (Item, Order, dsb)
///
/// PHASE 2 READY FOR FEATURES
/// [ ] Uji login flow end-to-end
/// [ ] Uji token refresh mechanism
/// [ ] Setup error handling UI
/// [ ] Setup loading state UI
/// [ ] Ready untuk development tim build features
///
/// DEPS YANG PERLU DITAMBAH KE pubspec.yaml:
/// - dio: ^5.0.0
/// - flutter_secure_storage: ^9.0.0
/// - riverpod: ^2.0.0 (atau provider/bloc sesuai pilihan)
/// - go_router: ^10.0.0 (untuk routing)
/// - freezed_annotation: ^2.0.0 (opsional, untuk model generation)
/// - json_annotation: ^4.0.0 (opsional, untuk JSON serialization)
