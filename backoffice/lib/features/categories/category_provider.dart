import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  CategoryNotifier(this._repository) : super(CategoryState()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _repository.getCategories(search: state.searchQuery);
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat kategori: $e');
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadCategories();
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    try {
      await _repository.createCategory(data);
      await loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal membuat kategori: $e');
      return false;
    }
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateCategory(id, data);
      await loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal memperbarui kategori: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus kategori: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
