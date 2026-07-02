import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../models/user_model.dart';

class AuthRepository {
  final _apiClient = ApiClient();

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.post('/auth/user/login', data: {'Username': email, 'Password': password});
      final data = response.data['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      if (accessToken != null) await _apiClient.secureStorage.saveAccessToken(accessToken);
      if (refreshToken != null) await _apiClient.secureStorage.saveRefreshToken(refreshToken);
      await _apiClient.secureStorage.saveUserId(user.id);
      await _apiClient.secureStorage.saveUserEmail(user.email);
      await _apiClient.secureStorage.saveUserName(user.name);
      await _apiClient.secureStorage.saveUserRole(user.role);
      if (user.branchId != null) await _apiClient.secureStorage.saveBranchId(user.branchId!);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final userId = await _apiClient.secureStorage.getUserId();
    final email = await _apiClient.secureStorage.getUserEmail();
    final name = await _apiClient.secureStorage.getUserName();
    final role = await _apiClient.secureStorage.getUserRole();
    final branchId = await _apiClient.secureStorage.getBranchId();
    if (userId == null || email == null || name == null || role == null) return null;
    return UserModel(id: userId, email: email, name: name, role: role, branchId: branchId, isActive: true, createdAt: DateTime.now());
  }

  Future<bool> isLoggedIn() async => _apiClient.secureStorage.isLoggedIn();

  Future<void> logout() async {
    final refreshToken = await _apiClient.secureStorage.getRefreshToken();
    try {
      if (refreshToken != null) await _apiClient.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {}
    await _apiClient.secureStorage.clearAuthData();
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _apiClient.secureStorage.getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final response = await _apiClient.post('/auth/refresh', data: {'refreshToken': refreshToken});
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;
      if (accessToken == null) return false;
      await _apiClient.secureStorage.saveAccessToken(accessToken);
      if (newRefreshToken != null) await _apiClient.secureStorage.saveRefreshToken(newRefreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }
}
