import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/discount_model.dart';
import 'repositories/discount_repository.dart';

class DiscountState {
  final List<DiscountModel> discounts;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  DiscountState({
    this.discounts = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  DiscountState copyWith({
    List<DiscountModel>? discounts,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return DiscountState(
      discounts: discounts ?? this.discounts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final discountProvider = StateNotifierProvider<DiscountNotifier, DiscountState>((ref) {
  final repository = ref.watch(discountRepositoryProvider);
  return DiscountNotifier(repository);
});

class DiscountNotifier extends StateNotifier<DiscountState> {
  final DiscountRepository _repository;

  DiscountNotifier(this._repository) : super(DiscountState()) {
    loadDiscounts();
  }

  Future<void> loadDiscounts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final discounts = await _repository.getDiscounts(search: state.searchQuery);
      state = state.copyWith(discounts: discounts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat diskon: $e');
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadDiscounts();
  }

  Future<bool> createDiscount(Map<String, dynamic> data) async {
    try {
      await _repository.createDiscount(data);
      await loadDiscounts();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal membuat diskon: $e');
      return false;
    }
  }

  Future<bool> updateDiscount(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateDiscount(id, data);
      await loadDiscounts();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal memperbarui diskon: $e');
      return false;
    }
  }

  Future<bool> deleteDiscount(String id) async {
    try {
      await _repository.deleteDiscount(id);
      await loadDiscounts();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus diskon: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
