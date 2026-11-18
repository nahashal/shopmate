import 'package:equatable/equatable.dart';

import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/shipping_address.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class CheckoutSubmitted extends CheckoutEvent {
  final String userId;
  final List<CartItem> items;
  final ShippingAddress address;
  final String paymentMethod;

  const CheckoutSubmitted({
    required this.userId,
    required this.items,
    required this.address,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [userId, items, address, paymentMethod];
}
