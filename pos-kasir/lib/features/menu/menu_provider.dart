import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../models/item_model.dart';
import 'repositories/menu_repository.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

// Categories
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(menuRepositoryProvider);
  return repo.getCategories();
});

// Items
final itemsProvider = FutureProvider<List<ItemModel>>((ref) async {
  final repo = ref.watch(menuRepositoryProvider);
  return repo.getItems();
});

// Selected category filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Filtered items by category
final filteredItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final itemsAsync = ref.watch(itemsProvider);

  return itemsAsync.whenData((items) {
    if (selectedCategory == null) return items;
    return items.where((item) => item.categoryId == selectedCategory).toList();
  });
});

// Search query
final menuSearchQueryProvider = StateProvider<String>((ref) => '');

// Search results
final searchItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final query = ref.watch(menuSearchQueryProvider).toLowerCase();
  final itemsAsync = ref.watch(itemsProvider);

  return itemsAsync.whenData((items) {
    if (query.isEmpty) return items;
    return items
        .where(
          (item) =>
              item.itemName.toLowerCase().contains(query) ||
              item.itemCode.toLowerCase().contains(query),
        )
        .toList();
  });
});
