import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/item_model.dart';
import '../../models/category_model.dart';
import '../../models/tax_model.dart';
import '../../models/discount_model.dart';
import 'repositories/item_repository.dart';
import '../categories/repositories/category_repository.dart';
import '../taxes/repositories/tax_repository.dart';
import '../discounts/repositories/discount_repository.dart';

class ItemState {
  final List<ItemModel> items;
  final List<CategoryModel> categories;
  final List<TaxModel> allTaxes;
  final List<DiscountModel> allDiscounts;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final String? selectedCategoryId;

  ItemState({
    this.items = const [],
    this.categories = const [],
    this.allTaxes = const [],
    this.allDiscounts = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.selectedCategoryId,
  });

  ItemState copyWith({
    List<ItemModel>? items,
    List<CategoryModel>? categories,
    List<TaxModel>? allTaxes,
    List<DiscountModel>? allDiscounts,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategoryId,
  }) {
    return ItemState(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      allTaxes: allTaxes ?? this.allTaxes,
      allDiscounts: allDiscounts ?? this.allDiscounts,
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
  final taxRepository = ref.watch(taxRepositoryProvider);
  final discountRepository = ref.watch(discountRepositoryProvider);
  return ItemNotifier(repository, catRepository, taxRepository, discountRepository);
});

class ItemNotifier extends StateNotifier<ItemState> {
  final ItemRepository _repository;
  final CategoryRepository _catRepository;
  final TaxRepository _taxRepository;
  final DiscountRepository _discountRepository;

  ItemNotifier(this._repository, this._catRepository, this._taxRepository, this._discountRepository)
      : super(ItemState()) {
    loadItems();
    loadCategories();
    loadTaxes();
    loadDiscounts();
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

  Future<void> loadTaxes() async {
    try {
      final taxes = await _taxRepository.getTaxes();
      state = state.copyWith(allTaxes: taxes);
    } catch (_) {}
  }

  Future<void> loadDiscounts() async {
    try {
      final discounts = await _discountRepository.getDiscounts();
      state = state.copyWith(allDiscounts: discounts);
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

  Future<bool> createItem(Map<String, dynamic> data, {List<String>? taxIds, List<String>? discountIds}) async {
    try {
      final item = await _repository.createItem(data);
      for (final id in taxIds ?? []) {
        await _repository.assignTaxToItem(item.id, id);
      }
      for (final id in discountIds ?? []) {
        await _repository.assignDiscountToItem(item.id, id);
      }
      await loadItems();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal membuat item: $e');
      return false;
    }
  }

  Future<bool> updateItem(String id, Map<String, dynamic> data, {List<String>? taxIds, List<String>? discountIds}) async {
    try {
      await _repository.updateItem(id, data);
      if (taxIds != null) {
        final current = await _repository.getItemTaxes(id);
        final currentIds = current.map((t) => t['TaxID'] as String).toSet();
        final newIds = taxIds.toSet();
        for (final tid in currentIds.difference(newIds)) {
          await _repository.removeTaxFromItem(id, tid);
        }
        for (final tid in newIds.difference(currentIds)) {
          await _repository.assignTaxToItem(id, tid);
        }
      }
      if (discountIds != null) {
        final current = await _repository.getItemDiscounts(id);
        final currentIds = current.map((d) => d['DiscountID'] as String).toSet();
        final newIds = discountIds.toSet();
        for (final did in currentIds.difference(newIds)) {
          await _repository.removeDiscountFromItem(id, did);
        }
        for (final did in newIds.difference(currentIds)) {
          await _repository.assignDiscountToItem(id, did);
        }
      }
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
