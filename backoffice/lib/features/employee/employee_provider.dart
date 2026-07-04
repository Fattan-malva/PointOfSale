import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/employee_model.dart';
import '../../models/role_model.dart';
import '../../models/branch_model.dart';
import 'repositories/employee_repository.dart';

class EmployeeState {
  final List<EmployeeModel> employees;
  final List<RoleModel> roles;
  final List<BranchModel> branches;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  EmployeeState({
    this.employees = const [],
    this.roles = const [],
    this.branches = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  EmployeeState copyWith({
    List<EmployeeModel>? employees,
    List<RoleModel>? roles,
    List<BranchModel>? branches,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      roles: roles ?? this.roles,
      branches: branches ?? this.branches,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final employeeProvider = StateNotifierProvider<EmployeeNotifier, EmployeeState>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  return EmployeeNotifier(repository);
});

class EmployeeNotifier extends StateNotifier<EmployeeState> {
  final EmployeeRepository _repository;

  EmployeeNotifier(this._repository) : super(EmployeeState()) {
    loadEmployees();
    loadRoles();
    loadBranches();
  }

  Future<void> loadEmployees() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final employees = await _repository.getEmployees(search: state.searchQuery);
      state = state.copyWith(employees: employees, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load employees: $e');
    }
  }

  Future<void> loadRoles() async {
    try {
      final roles = await _repository.getRoles();
      state = state.copyWith(roles: roles);
    } catch (_) {}
  }

  Future<void> loadBranches() async {
    try {
      final branches = await _repository.getBranches();
      state = state.copyWith(branches: branches);
    } catch (_) {}
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadEmployees();
  }

  Future<bool> createEmployee(Map<String, dynamic> data) async {
    try {
      await _repository.createEmployee(data);
      await loadEmployees();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create employee: $e');
      return false;
    }
  }

  Future<bool> updateEmployee(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateEmployee(id, data);
      await loadEmployees();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update employee: $e');
      return false;
    }
  }

  Future<bool> toggleActive(String id, bool isActive) async {
    try {
      await _repository.updateEmployee(id, {'IsActive': isActive});
      await loadEmployees();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update employee: $e');
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      await _repository.deleteEmployee(id);
      await loadEmployees();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete employee: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
