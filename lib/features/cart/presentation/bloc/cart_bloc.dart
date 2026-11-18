import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository;

  StreamSubscription<List<CartItem>>? _subscription;
  String? _userId;

  CartBloc(this._repository) : super(const CartState()) {
    on<CartStarted>(_onStarted);
    on<CartStopped>(_onStopped);
    on<CartUpdated>((event, emit) => emit(CartState(items: event.items)));
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartQuantityChanged>(_onQuantityChanged);
    on<CartCleared>(_onCleared);
  }

  Future<void> _onStarted(CartStarted event, Emitter<CartState> emit) async {
    await _subscription?.cancel();
    _userId = event.userId;

    emit(const CartState(isLoading: true));

    _subscription = _repository
        .watchCart(event.userId)
        .listen(
          (items) => add(CartUpdated(items)),
          onError: (_) => add(const CartUpdated([])),
        );
  }

  Future<void> _onStopped(CartStopped event, Emitter<CartState> emit) async {
    await _subscription?.cancel();
    _subscription = null;
    _userId = null;
    emit(const CartState());
  }

  Future<void> _onItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;

    final product = event.product;
    final current = state.quantityOf(product.id);

    await _run(emit, () {
      if (current == 0) {
        return _repository.addItem(userId, product);
      }
      if (current < product.stock) {
        return _repository.updateQuantity(userId, product.id, current + 1);
      }
      return Future.value(); // Already at stock limit
    });
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;

    await _run(emit, () => _repository.removeItem(userId, event.productId));
  }

  Future<void> _onQuantityChanged(
    CartQuantityChanged event,
    Emitter<CartState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;

    if (event.quantity <= 0) {
      await _run(emit, () => _repository.removeItem(userId, event.productId));
      return;
    }

    final item = state.items
        .where((item) => item.product.id == event.productId)
        .firstOrNull;
    if (item == null) return;

    final maxQuantity = item.product.stock;
    final quantity = event.quantity > maxQuantity
        ? maxQuantity
        : event.quantity;

    await _run(
      emit,
      () => _repository.updateQuantity(userId, event.productId, quantity),
    );
  }

  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) async {
    final userId = _userId;
    if (userId == null) return;

    await _run(emit, () => _repository.clearCart(userId));
  }

  /// Runs a Firestore write and shows a friendly error if it fails.
  Future<void> _run(
    Emitter<CartState> emit,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      // No emit needed: the Firestore stream sends the updated cart.
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Could not update your cart. Check your connection.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
