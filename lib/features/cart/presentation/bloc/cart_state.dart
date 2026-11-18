import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final bool isLoading;
  final String? errorMessage;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold<double>(0, (sum, item) => sum + item.total);

  int quantityOf(int productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, errorMessage];
}
