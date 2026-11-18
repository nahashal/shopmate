import '../../../products/domain/entities/product.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  Stream<List<CartItem>> watchCart(String userId);

  Future<void> addItem(String userId, Product product);

  Future<void> updateQuantity(String userId, int productId, int quantity);

  Future<void> removeItem(String userId, int productId);

  Future<void> clearCart(String userId);
}
