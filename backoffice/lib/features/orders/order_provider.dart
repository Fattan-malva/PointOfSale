import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/order_model.dart';
import 'repositories/order_repository.dart';

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;
  final String selectedStatus;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedStatus = 'all',
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    String? selectedStatus,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderNotifier(repository);
});

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;
  String? _branchId;

  OrderNotifier(this._repository) : super(OrderState());

  void setBranchId(String? id) {
    _branchId = id;
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await _repository.getOrders(
        branchId: _branchId,
        status: state.selectedStatus,
      );
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load orders: $e');
    }
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatus: status);
    loadOrders();
  }

  Future<bool> confirmOrder(String id) async {
    try {
      await _repository.confirmOrder(id);
      await loadOrders();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to confirm order: $e');
      return false;
    }
  }

  Future<bool> completeOrder(String id) async {
    try {
      await _repository.completeOrder(id);
      await loadOrders();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to complete order: $e');
      return false;
    }
  }

  Future<bool> cancelOrder(String id) async {
    try {
      await _repository.cancelOrder(id);
      await loadOrders();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to cancel order: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
