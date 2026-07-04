import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/role_model.dart';
import '../../models/permission_model.dart';
import 'repositories/role_repository.dart';

class RoleState {
  final List<RoleModel> roles;
  final List<PermissionModel> permissions;
  final List<PermissionModel> rolePermissions;
  final bool isLoading;
  final String? error;
  final String? selectedRoleId;

  RoleState({
    this.roles = const [],
    this.permissions = const [],
    this.rolePermissions = const [],
    this.isLoading = false,
    this.error,
    this.selectedRoleId,
  });

  RoleState copyWith({
    List<RoleModel>? roles,
    List<PermissionModel>? permissions,
    List<PermissionModel>? rolePermissions,
    bool? isLoading,
    String? error,
    String? selectedRoleId,
  }) {
    return RoleState(
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      rolePermissions: rolePermissions ?? this.rolePermissions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedRoleId: selectedRoleId ?? this.selectedRoleId,
    );
  }
}

final roleProvider = StateNotifierProvider<RoleNotifier, RoleState>((ref) {
  final repository = ref.watch(roleRepositoryProvider);
  return RoleNotifier(repository);
});

class RoleNotifier extends StateNotifier<RoleState> {
  final RoleRepository _repository;

  RoleNotifier(this._repository) : super(RoleState()) {
    loadRoles();
    loadPermissions();
  }

  Future<void> loadRoles() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final roles = await _repository.getRoles();
      state = state.copyWith(roles: roles, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load roles: $e');
    }
  }

  Future<void> loadPermissions() async {
    try {
      final permissions = await _repository.getPermissions();
      state = state.copyWith(permissions: permissions);
    } catch (_) {}
  }

  Future<void> selectRole(String roleId) async {
    state = state.copyWith(selectedRoleId: roleId);
    try {
      final rolePermissions = await _repository.getRolePermissions(roleId);
      final updatedPermissions = state.permissions.map((p) {
        final assigned = rolePermissions.any((rp) => rp.id == p.id);
        return PermissionModel(
          id: p.id,
          name: p.name,
          description: p.description,
          module: p.module,
          isAssigned: assigned,
        );
      }).toList();
      state = state.copyWith(permissions: updatedPermissions, rolePermissions: rolePermissions);
    } catch (_) {}
  }

  Future<bool> createRole(Map<String, dynamic> data) async {
    try {
      await _repository.createRole(data);
      await loadRoles();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create role: $e');
      return false;
    }
  }

  Future<bool> assignPermissions(String roleId, List<String> permissionIds) async {
    try {
      await _repository.assignPermissions(roleId, permissionIds);
      await selectRole(roleId);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to assign permissions: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
