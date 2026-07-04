import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/table_model.dart';
import '../../models/branch_model.dart';
import 'repositories/table_repository.dart';
import '../branch/repositories/branch_repository.dart';

class TableState {
  final List<TableModel> tables;
  final List<BranchModel> branches;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  TableState({
    this.tables = const [],
    this.branches = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  TableState copyWith({
    List<TableModel>? tables,
    List<BranchModel>? branches,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return TableState(
      tables: tables ?? this.tables,
      branches: branches ?? this.branches,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final tableProvider = StateNotifierProvider<TableNotifier, TableState>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  final branchRepository = ref.watch(branchRepositoryProvider);
  return TableNotifier(repository, branchRepository);
});

class TableNotifier extends StateNotifier<TableState> {
  final TableRepository _repository;
  final BranchRepository _branchRepository;

  TableNotifier(this._repository, this._branchRepository)
      : super(TableState()) {
    loadTables();
    loadBranches();
  }

  Future<void> refresh() async {
    await Future.wait([
      loadTables(),
      loadBranches(),
    ]);
  }

  Future<void> loadTables() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tables = await _repository.getTables(search: state.searchQuery);
      state = state.copyWith(tables: tables, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat meja: $e');
    }
  }

  Future<void> loadBranches() async {
    try {
      final branches = await _branchRepository.getBranches();
      state = state.copyWith(branches: branches);
    } catch (_) {}
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadTables();
  }

  Future<bool> createTable(Map<String, dynamic> data) async {
    try {
      await _repository.createTable(data);
      await loadTables();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal membuat meja: $e');
      return false;
    }
  }

  Future<bool> updateTable(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateTable(id, data);
      await loadTables();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal memperbarui meja: $e');
      return false;
    }
  }

  Future<bool> deleteTable(String id) async {
    try {
      await _repository.deleteTable(id);
      await loadTables();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus meja: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
