import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../storage/storage_keys.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility:
          KeychainAccessibility.first_available_when_unlocked_this_device_only,
    ),
  );

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: StorageKeys.userId, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: StorageKeys.userId);
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: StorageKeys.userEmail, value: email);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: StorageKeys.userEmail);
  }

  /// Save user name
  Future<void> saveUserName(String name) async {
    await _storage.write(key: StorageKeys.userName, value: name);
  }

  /// Get user name
  Future<String?> getUserName() async {
    return await _storage.read(key: StorageKeys.userName);
  }

  /// Save user role
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: StorageKeys.userRole, value: role);
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return await _storage.read(key: StorageKeys.userRole);
  }

  /// Save branch ID
  Future<void> saveBranchId(String branchId) async {
    await _storage.write(key: StorageKeys.branchId, value: branchId);
  }

  /// Get branch ID
  Future<String?> getBranchId() async {
    return await _storage.read(key: StorageKeys.branchId);
  }

  /// Clear all auth data (logout)
  Future<void> clearAuthData() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.userEmail);
    await _storage.delete(key: StorageKeys.userName);
    await _storage.delete(key: StorageKeys.userRole);
    await _storage.delete(key: StorageKeys.branchId);
  }

  /// Check if user is logged in (has access token)
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
