import 'package:equatable/equatable.dart';

import '../../../cart/domain/entities/cart_item.dart';
import 'order_request.dart';
import 'shipping_address.dart';

enum OrderStatus {
  placed,
  shipped,
  delivered,
  cancelled,
  returnRequested,
  returned,
  exchangeRequested,
  exchanged,
}

class ShopOrder extends Equatable {
  final String id;
  final List<CartItem> items;
  final ShippingAddress address;
  final double subtotal;
  final double shippingFee;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  /// The cancel / return / exchange request, if the user made one.
  final OrderRequest? request;

  const ShopOrder({
    required this.id,
    required this.items,
    required this.address,
    required this.subtotal,
    required this.shippingFee,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.request,
  });

  double get total => subtotal + shippingFee;

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Only orders that haven't shipped can be cancelled.
  bool get canCancel => status == OrderStatus.placed;

  /// Returns and exchanges need the order to have arrived.
  bool get canReturnOrExchange => status == OrderStatus.delivered;

  @override
  List<Object?> get props => [
    id,
    items,
    address,
    subtotal,
    shippingFee,
    paymentMethod,
    status,
    createdAt,
    request,
  ];
}
