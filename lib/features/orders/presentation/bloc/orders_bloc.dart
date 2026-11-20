import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository _repository;

  OrdersBloc(this._repository) : super(const OrdersState()) {
    on<OrdersStarted>(_onStarted);
  }

  Future<void> _onStarted(
    OrdersStarted event,
    Emitter<OrdersState> emit,
  ) async {
    await emit.forEach<List<ShopOrder>>(
      _repository.watchOrders(event.userId),
      onData: (orders) =>
          OrdersState(status: OrdersStatus.loaded, orders: orders),
      onError: (error, stackTrace) => const OrdersState(
        status: OrdersStatus.failure,
        errorMessage: 'Could not load your orders.',
      ),
    );
  }
}
