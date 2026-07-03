import '../../models/user_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class AuthRepository {
  final _apiClient = ApiClient();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/user/login',
        data: {'Username': email, 'Password': password},
      );

      // Parse response: { data: { accessToken, refreshToken, user: {...} } }
      final data = response.data['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      if (accessToken == null || refreshToken == null) {
        throw ApiException(message: 'Invalid login response: missing tokens');
      }

      await _apiClient.secureStorage.saveAccessToken(accessToken);
      await _apiClient.secureStorage.saveRefreshToken(refreshToken);
      await _apiClient.secureStorage.saveUserId(user.id);
      await _apiClient.secureStorage.saveUserEmail(user.email);
      await _apiClient.secureStorage.saveUserName(user.name);
      await _apiClient.secureStorage.saveUserRole(user.role);
      if (user.branchId != null) {
        await _apiClient.secureStorage.saveBranchId(user.branchId!);
      }

      return user;
    } on ApiException catch (e) {
      throw ApiException(message: 'Login failed: ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Login failed: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = await _apiClient.secureStorage.getUserId();
      final email = await _apiClient.secureStorage.getUserEmail();
      final name = await _apiClient.secureStorage.getUserName();
      final role = await _apiClient.secureStorage.getUserRole();
      final branchId = await _apiClient.secureStorage.getBranchId();

      if (userId == null || email == null || name == null || role == null) {
        return null;
      }

      return UserModel(
        id: userId,
        email: email,
        name: name,
        role: role,
        branchId: branchId,
        isActive: true,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    return await _apiClient.secureStorage.isLoggedIn();
  }

  Future<void> logout() async {
    try {
      //
    } catch (e) {
      //
    } finally {
      await _apiClient.secureStorage.clearAuthData();
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _apiClient.secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await _apiClient.post(
        '/auth/user/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;

      if (newAccessToken != null) {
        await _apiClient.secureStorage.saveAccessToken(newAccessToken);
        if (newRefreshToken != null) {
          await _apiClient.secureStorage.saveRefreshToken(newRefreshToken);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
