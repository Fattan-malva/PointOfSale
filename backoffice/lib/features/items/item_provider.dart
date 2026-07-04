import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/item_model.dart';
import '../../models/category_model.dart';
import 'repositories/item_repository.dart';
import '../categories/repositories/category_repository.dart';

class ItemState {
  final List<ItemModel> items;
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final String? selectedCategoryId;

  ItemState({
    this.items = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.selectedCategoryId,
  });

  ItemState copyWith({
    List<ItemModel>? items,
    List<CategoryModel>? categories,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategoryId,
  }) {
    return ItemState(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

final itemProvider = StateNotifierProvider<ItemNotifier, ItemState>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  final catRepository = ref.watch(categoryRepositoryProvider);
  return ItemNotifier(repository, catRepository);
});

class ItemNotifier extends StateNotifier<ItemState> {
  final ItemRepository _repository;
  final CategoryRepository _catRepository;

  ItemNotifier(this._repository, this._catRepository) : super(ItemState()) {
    loadItems();
    loadCategories();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repository.getItems(
        search: state.searchQuery,
        categoryId: state.selectedCategoryId,
        itemType: 'Product',
      );
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat item: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _catRepository.getCategories();
      state = state.copyWith(categories: categories);
    } catch (_) {}
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadItems();
  }

  void setCategoryFilter(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
    loadItems();
  }

  Future<bool> createItem(Map<String, dynamic> data) async {
    try {
      await _repository.createItem(data);
      await loadItems();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal membuat item: $e');
      return false;
    }
  }

  Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateItem(id, data);
      await loadItems();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal memperbarui item: $e');
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _repository.deleteItem(id);
      await loadItems();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus item: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
