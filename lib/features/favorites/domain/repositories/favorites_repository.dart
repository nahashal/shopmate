import '../../../products/domain/entities/product.dart';

abstract class FavoritesRepository {
  /// Emits the user's favourites every time they change.
  Stream<List<Product>> watchFavorites(String userId);

  Future<void> addFavorite(String userId, Product product);

  Future<void> removeFavorite(String userId, int productId);
}
