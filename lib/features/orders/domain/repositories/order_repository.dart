import '../../../cart/domain/entities/cart_item.dart';
import '../entities/order.dart';
import '../entities/shipping_address.dart';

abstract class OrderRepository {
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
