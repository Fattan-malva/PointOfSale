import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_exception.dart';
import '../../models/category_model.dart';
import 'repositories/category_repository.dart';

class CategoryState {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryNotifier(repository);
});

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository _repository;
  Timer? _debounce;
  int _queryId = 0;

  CategoryNotifier(this._repository) : super(CategoryState()) {
    loadCategories();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> loadCategories({String? query}) async {
    final qId = ++_queryId;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _repository.getCategories(search: query ?? state.searchQuery);
      if (qId == _queryId) {
        state = state.copyWith(categories: categories, isLoading: false);
      }
    } catch (e) {
      if (qId == _queryId) {
        state = state.copyWith(isLoading: false, error: _fmtErr(e));
      }
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      loadCategories(query: query.isEmpty ? null : query);
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    state = state.copyWith(searchQuery: null);
    loadCategories();
  }

  /// Returns null on success, error message on failure.
  Future<String?> createCategory(Map<String, dynamic> data) async {
    try {
      await _repository.createCategory(data);
      await loadCategories();
      return null;
    } catch (e) {
      final msg = _fmtErr(e);
      state = state.copyWith(error: msg);
      return msg;
    }
  }

  Future<String?> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateCategory(id, data);
      await loadCategories();
      return null;
    } catch (e) {
      final msg = _fmtErr(e);
      state = state.copyWith(error: msg);
      return msg;
    }
  }

  Future<String?> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      await loadCategories();
      return null;
    } catch (e) {
      final msg = _fmtErr(e);
      state = state.copyWith(error: msg);
      return msg;
    }
  }

  String _fmtErr(Object e) {
    if (e is ApiException) return e.message;
    return e.toString();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
