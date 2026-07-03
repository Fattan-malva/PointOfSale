import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import 'auth_repository.dart';
import '../../core/network/api_exception.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _repository.getCurrentUser();
        state = AuthState(isAuthenticated: true, user: user, isLoading: false);
      } else {
        state = AuthState(isLoading: false);
      }
    } catch (e) {
      state = AuthState(isLoading: false, error: 'Failed to initialize auth');
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email: email, password: password);
      state = AuthState(isAuthenticated: true, user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        isAuthenticated: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: $e',
        isAuthenticated: false,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
      state = AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Logout failed: $e');
    }
  }

  Future<bool> refreshToken() async {
    try {
      final success = await _repository.refreshToken();
      if (success) {
        final user = await _repository.getCurrentUser();
        state = state.copyWith(user: user);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
