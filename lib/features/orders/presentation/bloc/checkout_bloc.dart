import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/order_repository.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final OrderRepository _repository;

  CheckoutBloc(this._repository) : super(const CheckoutState()) {
    on<CheckoutSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CheckoutSubmitted event,
    Emitter<CheckoutState> emit,
  ) async {
    if (event.items.isEmpty) {
      emit(
        const CheckoutState(
          status: CheckoutStatus.failure,
          errorMessage: 'Your cart is empty.',
        ),
      );
      return;
    }

    emit(const CheckoutState(status: CheckoutStatus.submitting));

    try {
      final orderId = await _repository.placeOrder(
        userId: event.userId,
        items: event.items,
        address: event.address,
        paymentMethod: event.paymentMethod,
      );

      emit(CheckoutState(status: CheckoutStatus.success, orderId: orderId));
    } catch (_) {
      emit(
        const CheckoutState(
          status: CheckoutStatus.failure,
          errorMessage: 'Could not place your order. Check your connection and try again.',
        ),
      );
    }
  }
}
