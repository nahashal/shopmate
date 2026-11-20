import '../entities/product_page.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<ProductPage> call({
    int limit = 20,
    int skip = 0,
    String category = 'all',
    String query = '',
  }) {
    return repository.getProducts(
      limit: limit,
      skip: skip,
      category: category,
      query: query,
    );
  }
}
