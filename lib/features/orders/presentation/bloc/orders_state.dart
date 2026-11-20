import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';

enum OrdersStatus { loading, loaded, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<ShopOrder> orders;
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.loading,
    this.orders = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, orders, errorMessage];
}
