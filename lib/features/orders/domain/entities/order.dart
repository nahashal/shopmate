import 'package:equatable/equatable.dart';

import '../../../cart/domain/entities/cart_item.dart';
import 'shipping_address.dart';

enum OrderStatus { placed, shipped, delivered, cancelled }

class Order extends Equatable {
  final String id;
  final List<CartItem> items;
  final ShippingAddress address;
  final double subtotal;
  final double shippingFee;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.items,
    required this.address,
    required this.subtotal,
    required this.shippingFee,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  double get total => subtotal + shippingFee;

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

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
  ];
}
