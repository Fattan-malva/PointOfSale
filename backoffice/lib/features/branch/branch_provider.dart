import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/branch_model.dart';
import 'repositories/branch_repository.dart';

class BranchState {
  final List<BranchModel> branches;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  BranchState({
    this.branches = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  BranchState copyWith({
    List<BranchModel>? branches,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return BranchState(
      branches: branches ?? this.branches,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final branchProvider = StateNotifierProvider<BranchNotifier, BranchState>((ref) {
  final repository = ref.watch(branchRepositoryProvider);
  return BranchNotifier(repository);
});

class BranchNotifier extends StateNotifier<BranchState> {
  final BranchRepository _repository;

  BranchNotifier(this._repository) : super(BranchState()) {
    loadBranches();
  }

  Future<void> loadBranches() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final branches = await _repository.getBranches(search: state.searchQuery);
      state = state.copyWith(branches: branches, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load branches: $e');
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadBranches();
  }

  Future<bool> createBranch(Map<String, dynamic> data) async {
    try {
      await _repository.createBranch(data);
      await loadBranches();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create branch: $e');
      return false;
    }
  }

  Future<bool> updateBranch(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateBranch(id, data);
      await loadBranches();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update branch: $e');
      return false;
    }
  }

  Future<bool> deleteBranch(String id) async {
    try {
      await _repository.deleteBranch(id);
      await loadBranches();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete branch: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
