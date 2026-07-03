import '../../core/network/api_client.dart';
import '../../models/user_model.dart';
import '../../core/network/api_exception.dart';

class AuthRepository {
  final _apiClient = ApiClient();

  Future<UserModel> login({required String email, required String password}) async {
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
      
      if (accessToken == null || refreshToken == null) {
        throw ApiException(message: 'Invalid login response: missing tokens');
      }

      final user = UserModel.fromJson(userData);
      
      // Save tokens and user data to secure storage
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
    try {
      return await _apiClient.secureStorage.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _apiClient.secureStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Optional: call logout endpoint if backend supports it
          await _apiClient.post('/auth/logout', data: {'refreshToken': refreshToken});
        } catch (_) {
          // Ignore errors on logout endpoint
        }
      }
    } catch (e) {
      // Continue with clearing data even if endpoint fails
    } finally {
      await _apiClient.secureStorage.clearAuthData();
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _apiClient.secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      
      final data = response.data['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;
      
      if (accessToken == null) {
        return false;
      }

      await _apiClient.secureStorage.saveAccessToken(accessToken);
      if (newRefreshToken != null) {
        await _apiClient.secureStorage.saveRefreshToken(newRefreshToken);
      }
      
      return true;
    } catch (e) {
      // Token refresh failed, user will need to login again
      return false;
    }
  }
}
