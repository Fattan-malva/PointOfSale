import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/modifier_model.dart';
import 'repositories/modifier_repository.dart';

class ModifierState {
  final List<ModifierModel> modifiers;
  final List<ModifierOptionModel> currentOptions;
  final bool isLoading;
  final bool isLoadingOptions;
  final String? error;
  final String? searchQuery;
  final String? selectedModifierId;

  ModifierState({
    this.modifiers = const [],
    this.currentOptions = const [],
    this.isLoading = false,
    this.isLoadingOptions = false,
    this.error,
    this.searchQuery,
    this.selectedModifierId,
  });

  ModifierState copyWith({
    List<ModifierModel>? modifiers,
    List<ModifierOptionModel>? currentOptions,
    bool? isLoading,
    bool? isLoadingOptions,
    String? error,
    String? searchQuery,
    String? selectedModifierId,
  }) {
    return ModifierState(
      modifiers: modifiers ?? this.modifiers,
      currentOptions: currentOptions ?? this.currentOptions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedModifierId: selectedModifierId ?? this.selectedModifierId,
    );
  }
}

final modifierProvider = StateNotifierProvider<ModifierNotifier, ModifierState>((ref) {
  final repository = ref.watch(modifierRepositoryProvider);
  return ModifierNotifier(repository);
});

class ModifierNotifier extends StateNotifier<ModifierState> {
  final ModifierRepository _repository;

  ModifierNotifier(this._repository) : super(ModifierState()) {
    loadModifiers();
  }

  Future<void> loadModifiers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final modifiers = await _repository.getModifiers(search: state.searchQuery);
      state = state.copyWith(modifiers: modifiers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat modifier: $e');
    }
  }

  Future<void> loadOptions(String modifierId) async {
    state = state.copyWith(selectedModifierId: modifierId, isLoadingOptions: true);
    try {
      final options = await _repository.getModifierOptions(modifierId);
      state = state.copyWith(currentOptions: options, isLoadingOptions: false);
    } catch (e) {
      state = state.copyWith(isLoadingOptions: false, error: 'Gagal memuat opsi: $e');
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadModifiers();
  }

  Future<bool> createModifier(Map<String, dynamic> data) async {
    try {
      await _repository.createModifier(data);
      await loadModifiers();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal membuat modifier: $e');
      return false;
    }
  }

  Future<bool> updateModifier(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateModifier(id, data);
      await loadModifiers();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal memperbarui modifier: $e');
      return false;
    }
  }

  Future<bool> deleteModifier(String id) async {
    try {
      await _repository.deleteModifier(id);
      state = state.copyWith(selectedModifierId: state.selectedModifierId == id ? null : state.selectedModifierId);
      await loadModifiers();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus modifier: $e');
      return false;
    }
  }

  Future<bool> createOption(String modifierId, Map<String, dynamic> data) async {
    try {
      await _repository.createOption(modifierId, data);
      await loadOptions(modifierId);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal membuat opsi: $e');
      return false;
    }
  }

  Future<bool> updateOption(String optionId, Map<String, dynamic> data) async {
    try {
      final modId = state.selectedModifierId;
      await _repository.updateOption(optionId, data);
      if (modId != null) await loadOptions(modId);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal memperbarui opsi: $e');
      return false;
    }
  }

  Future<bool> deleteOption(String optionId) async {
    try {
      final modId = state.selectedModifierId;
      await _repository.deleteOption(optionId);
      if (modId != null) await loadOptions(modId);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus opsi: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
