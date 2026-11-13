import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartQuantityChanged>(_onQuantityChanged);
    on<CartCleared>((event, emit) => emit(const CartState()));
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);

    final index = items.indexWhere(
      (item) => item.product.id == event.product.id,
    );

    if (index >= 0) {
      // Already in cart: increase quantity, but not beyond stock
      final existing = items[index];
      if (existing.quantity < event.product.stock) {
        items[index] = existing.copyWith(quantity: existing.quantity + 1);
      }
    } else {
      // New product: add with quantity 1
      items.add(CartItem(product: event.product));
    }

    emit(CartState(items: items));
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final items = state.items
        .where((item) => item.product.id != event.productId)
        .toList();

    emit(CartState(items: items));
  }

  void _onQuantityChanged(CartQuantityChanged event, Emitter<CartState> emit) {
    // Quantity 0 or less means remove the item
    if (event.quantity <= 0) {
      _onItemRemoved(CartItemRemoved(event.productId), emit);
      return;
    }

    final items = state.items.map((item) {
      if (item.product.id != event.productId) return item;

      final maxQuantity = item.product.stock;
      final newQuantity = event.quantity > maxQuantity
          ? maxQuantity
          : event.quantity;

      return item.copyWith(quantity: newQuantity);
    }).toList();

    emit(CartState(items: items));
  }
}
