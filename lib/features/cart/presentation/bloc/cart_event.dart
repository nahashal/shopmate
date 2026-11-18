import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';
import '../../../products/domain/entities/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartItemAdded extends CartEvent {
  final Product product;

  const CartItemAdded(this.product);

  @override
  List<Object?> get props => [product];
}

class CartItemRemoved extends CartEvent {
  final int productId;

  const CartItemRemoved(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CartQuantityChanged extends CartEvent {
  final int productId;
  final int quantity;

  const CartQuantityChanged({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

// Start listening to a user's cart (sent after login).
class CartStarted extends CartEvent {
  final String userId;

  const CartStarted(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Stop listening and empty the local cart (sent after logout).
// Does NOT delete anything from Firestore.
class CartStopped extends CartEvent {
  const CartStopped();
}

// Used inside the BLoC when Firestore sends new data.
class CartUpdated extends CartEvent {
  final List<CartItem> items;

  const CartUpdated(this.items);

  @override
  List<Object?> get props => [items];
}
