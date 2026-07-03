import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import 'repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository();
});

final paymentMethodsProvider = FutureProvider<List<PaymentMethodModel>>((
  ref,
) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getPaymentMethods();
});

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((
  ref,
) {
  return PaymentNotifier(ref);
});

class PaymentState {
  final bool isLoading;
  final String? error;
  final PaymentModel? payment;
  final bool success;

  PaymentState({
    this.isLoading = false,
    this.error,
    this.payment,
    this.success = false,
  });

  PaymentState copyWith({
    bool? isLoading,
    String? error,
    PaymentModel? payment,
    bool? success,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      payment: payment ?? this.payment,
      success: success ?? this.success,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final _repo = PaymentRepository();

  PaymentNotifier(Ref ref) : super(PaymentState());

  Future<void> processPayment(
    String orderId, {
    required String paymentMethodId,
    required double paymentAmount,
    String? referenceNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final payment = await _repo.processPayment(
        orderId,
        paymentMethodId: paymentMethodId,
        paymentAmount: paymentAmount,
        referenceNumber: referenceNumber,
      );
      state = state.copyWith(isLoading: false, payment: payment, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = PaymentState();
  }
}
