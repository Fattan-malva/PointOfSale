import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../storage/storage_keys.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(),
  );

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: StorageKeys.userId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: StorageKeys.userId);
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: StorageKeys.userEmail, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: StorageKeys.userEmail);
  }

  Future<void> saveUserName(String name) async {
    await _storage.write(key: StorageKeys.userName, value: name);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: StorageKeys.userName);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: StorageKeys.userRole, value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: StorageKeys.userRole);
  }

  Future<void> saveBranchId(String branchId) async {
    await _storage.write(key: StorageKeys.branchId, value: branchId);
  }

  Future<String?> getBranchId() async {
    return await _storage.read(key: StorageKeys.branchId);
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.userEmail);
    await _storage.delete(key: StorageKeys.userName);
    await _storage.delete(key: StorageKeys.userRole);
    await _storage.delete(key: StorageKeys.branchId);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
