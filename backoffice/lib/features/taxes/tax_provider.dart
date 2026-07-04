import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tax_model.dart';
import 'repositories/tax_repository.dart';

class TaxState {
  final List<TaxModel> taxes;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  TaxState({
    this.taxes = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  TaxState copyWith({
    List<TaxModel>? taxes,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return TaxState(
      taxes: taxes ?? this.taxes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final taxProvider = StateNotifierProvider<TaxNotifier, TaxState>((ref) {
  final repository = ref.watch(taxRepositoryProvider);
  return TaxNotifier(repository);
});

class TaxNotifier extends StateNotifier<TaxState> {
  final TaxRepository _repository;

  TaxNotifier(this._repository) : super(TaxState()) {
    loadTaxes();
  }

  Future<void> loadTaxes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final taxes = await _repository.getTaxes(search: state.searchQuery);
      state = state.copyWith(taxes: taxes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat pajak: $e');
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadTaxes();
  }

  Future<bool> createTax(Map<String, dynamic> data) async {
    try {
      await _repository.createTax(data);
      await loadTaxes();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal membuat pajak: $e');
      return false;
    }
  }

  Future<bool> updateTax(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateTax(id, data);
      await loadTaxes();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal memperbarui pajak: $e');
      return false;
    }
  }

  Future<bool> deleteTax(String id) async {
    try {
      await _repository.deleteTax(id);
      await loadTaxes();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus pajak: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
