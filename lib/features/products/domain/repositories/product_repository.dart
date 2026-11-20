import '../entities/product_page.dart';

abstract class ProductRepository {
  /// Loads one page of products.
  ///
  /// - [query] not empty → searches all products.
  /// - [category] not 'all' → only that category.
  /// - otherwise → all products.
  Future<ProductPage> getProducts({
    int limit = 20,
    int skip = 0,
    String category = 'all',
    String query = '',
  });

  /// The full list of category slugs, e.g. ['beauty', 'laptops', ...].
  Future<List<String>> getCategories();
}
