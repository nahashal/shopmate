import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/order_action_failure.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_request_event.dart';
import 'order_request_state.dart';

class OrderRequestBloc extends Bloc<OrderRequestEvent, OrderRequestState> {
  final OrderRepository _repository;

  OrderRequestBloc(this._repository) : super(const OrderRequestState()) {
    on<OrderRequestSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    OrderRequestSubmitted event,
    Emitter<OrderRequestState> emit,
  ) async {
    if (state.isSubmitting) return;

    emit(const OrderRequestState(status: OrderRequestStatus.submitting));

    try {
      await _repository.submitRequest(
        userId: event.userId,
        orderId: event.orderId,
        request: event.request,
      );
      emit(const OrderRequestState(status: OrderRequestStatus.success));
    } on OrderActionFailure catch (e) {
      emit(
        OrderRequestState(
          status: OrderRequestStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        const OrderRequestState(
          status: OrderRequestStatus.failure,
          errorMessage: 'Could not send your request. Check your connection and try again.',
        ),
      );
    }
  }
}
