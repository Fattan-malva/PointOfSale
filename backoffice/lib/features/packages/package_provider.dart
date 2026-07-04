import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/item_model.dart';
import '../../models/modifier_model.dart';
import 'repositories/package_repository.dart';
import '../items/repositories/item_repository.dart';

class PackageState {
  final List<ItemModel> packages;
  final List<PackageDetailModel> packageDetails;
  final List<ItemModel> availableItems;
  final bool isLoading;
  final bool isLoadingDetails;
  final String? error;
  final String? searchQuery;
  final String? selectedPackageId;

  PackageState({
    this.packages = const [],
    this.packageDetails = const [],
    this.availableItems = const [],
    this.isLoading = false,
    this.isLoadingDetails = false,
    this.error,
    this.searchQuery,
    this.selectedPackageId,
  });

  PackageState copyWith({
    List<ItemModel>? packages,
    List<PackageDetailModel>? packageDetails,
    List<ItemModel>? availableItems,
    bool? isLoading,
    bool? isLoadingDetails,
    String? error,
    String? searchQuery,
    String? selectedPackageId,
  }) {
    return PackageState(
      packages: packages ?? this.packages,
      packageDetails: packageDetails ?? this.packageDetails,
      availableItems: availableItems ?? this.availableItems,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPackageId: selectedPackageId ?? this.selectedPackageId,
    );
  }
}

final packageProvider = StateNotifierProvider<PackageNotifier, PackageState>((ref) {
  final repository = ref.watch(packageRepositoryProvider);
  final itemRepository = ref.watch(itemRepositoryProvider);
  return PackageNotifier(repository, itemRepository);
});

class PackageNotifier extends StateNotifier<PackageState> {
  final PackageRepository _repository;
  final ItemRepository _itemRepository;

  PackageNotifier(this._repository, this._itemRepository) : super(PackageState()) {
    loadPackages();
  }

  Future<void> loadPackages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final packages = await _repository.getPackages(search: state.searchQuery);
      state = state.copyWith(packages: packages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat paket: $e');
    }
  }

  Future<void> loadPackageDetails(String packageId) async {
    state = state.copyWith(selectedPackageId: packageId, isLoadingDetails: true);
    try {
      final details = await _repository.getPackageDetails(packageId);
      final items = await _itemRepository.getItems(itemType: 'Product');
      state = state.copyWith(packageDetails: details, availableItems: items, isLoadingDetails: false);
    } catch (e) {
      state = state.copyWith(isLoadingDetails: false, error: 'Gagal memuat detail paket: $e');
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadPackages();
  }

  Future<bool> createPackage(Map<String, dynamic> data) async {
    try {
      await _repository.createPackage(data);
      await loadPackages();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal membuat paket: $e');
      return false;
    }
  }

  Future<bool> updatePackage(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updatePackage(id, data);
      await loadPackages();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal memperbarui paket: $e');
      return false;
    }
  }

  Future<bool> deletePackage(String id) async {
    try {
      await _repository.deletePackage(id);
      state = state.copyWith(selectedPackageId: state.selectedPackageId == id ? null : state.selectedPackageId);
      await loadPackages();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus paket: $e');
      return false;
    }
  }

  Future<bool> addDetail(String packageId, String itemId, int qty) async {
    try {
      await _repository.addPackageDetail(packageId, itemId, qty);
      await loadPackageDetails(packageId);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal menambah item ke paket: $e');
      return false;
    }
  }

  Future<bool> removeDetail(String packageId, String detailId) async {
    try {
      await _repository.removePackageDetail(packageId, detailId);
      await loadPackageDetails(packageId);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus item dari paket: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
