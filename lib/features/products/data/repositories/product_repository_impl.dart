import '../../domain/entities/product_page.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProductPage> getProducts({
    int limit = 20,
    int skip = 0,
    String category = 'all',
    String query = '',
  }) {
    return remoteDataSource.getProducts(
      limit: limit,
      skip: skip,
      category: category,
      query: query,
    );
  }

  @override
  Future<List<String>> getCategories() => remoteDataSource.getCategories();
}
