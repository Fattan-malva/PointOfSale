import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/order_model.dart';
import 'repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

// Current active order (Draft/Confirmed)
final currentOrderProvider = StateNotifierProvider<OrderNotifier, OrderState>((
  ref,
) {
  return OrderNotifier(ref);
});

class OrderState {
  final OrderModel? order;
  final bool isLoading;
  final String? error;

  OrderState({this.order, this.isLoading = false, this.error});

  OrderState copyWith({
    OrderModel? order,
    bool? isLoading,
    String? error,
    bool clearOrder = false,
  }) {
    return OrderState(
      order: clearOrder ? null : (order ?? this.order),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get itemCount => order?.itemCount ?? 0;
  double get subtotal => order?.subtotal ?? 0;
  double get taxAmount => order?.taxAmount ?? 0;
  double get discountAmount => order?.discountAmount ?? 0;
  double get totalAmount => order?.totalAmount ?? 0;
  bool get hasOrder => order != null;
  bool get isEmpty => order == null || order!.details.isEmpty;
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref _ref;
  final _repo = OrderRepository();

  OrderNotifier(this._ref) : super(OrderState());

  Future<void> createOrder({
    required String branchId,
    required String userId,
    String? tableId,
    required String orderType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final order = await _repo.createOrder(
        branchId: branchId,
        userId: userId,
        tableId: tableId,
        orderType: orderType,
      );
      state = state.copyWith(order: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addItem(String itemId, {double qty = 1, String? note}) async {
    if (state.order == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.addItemToOrder(
        state.order!.id,
        itemId: itemId,
        qty: qty,
        note: note,
      );
      // Reload order to get updated details
      final order = await _repo.getOrderById(state.order!.id);
      state = state.copyWith(order: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateItemQty(String detailId, double qty) async {
    if (state.order == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (qty <= 0) {
        await _repo.removeOrderItem(state.order!.id, detailId);
      } else {
        await _repo.updateOrderItem(state.order!.id, detailId, qty: qty);
      }
      final order = await _repo.getOrderById(state.order!.id);
      state = state.copyWith(order: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeItem(String detailId) async {
    if (state.order == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.removeOrderItem(state.order!.id, detailId);
      final order = await _repo.getOrderById(state.order!.id);
      state = state.copyWith(order: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> confirmOrder() async {
    if (state.order == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final order = await _repo.confirmOrder(state.order!.id);
      state = state.copyWith(order: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> cancelOrder() async {
    if (state.order == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final order = await _repo.cancelOrder(state.order!.id);
      state = state.copyWith(order: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearOrder() {
    state = state.copyWith(clearOrder: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Order history
final orderHistoryProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrders();
});
