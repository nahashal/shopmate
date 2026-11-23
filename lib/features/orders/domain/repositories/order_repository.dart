import '../../../cart/domain/entities/cart_item.dart';
import '../entities/order.dart';
import '../entities/shipping_address.dart';
import '../entities/order_request.dart';

abstract class OrderRepository {
  /// Cancels the order, or requests a return or exchange.
  /// Throws OrderActionFailure if the order's status doesn't allow it.
  Future<void> submitRequest({
    required String userId,
    required String orderId,
    required OrderRequest request,
  });

  /// Emits the user's orders, newest first.
  Stream<List<ShopOrder>> watchOrders(String userId);

  /// Saves the order and empties the cart. Returns the new order's ID.
  Future<String> placeOrder({
    required String userId,
    required List<CartItem> items,
    required ShippingAddress address,
    required String paymentMethod,
  });
}
