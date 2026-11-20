import 'package:dio/dio.dart';

import '../../domain/entities/product_page.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductPage> getProducts({
    int limit = 20,
    int skip = 0,
    String category = 'all',
    String query = '',
  });

  Future<List<String>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProductPage> getProducts({
    int limit = 20,
    int skip = 0,
    String category = 'all',
    String query = '',
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit, 'skip': skip};

    // Pick the DummyJSON endpoint for what the user is looking at
    final String path;
    if (query.isNotEmpty) {
      path = '/products/search';
      queryParameters['q'] = query;
    } else if (category != 'all') {
      path = '/products/category/${Uri.encodeComponent(category)}';
    } else {
      path = '/products';
    }

    final response = await dio.get(path, queryParameters: queryParameters);
    final data = response.data;

    if (data is! Map || data['products'] is! List) {
      throw const FormatException('Invalid product response from server');
    }

    final products = (data['products'] as List)
        .map(
          (product) =>
              ProductModel.fromJson(Map<String, dynamic>.from(product as Map)),
        )
        .toList();

    final total = (data['total'] as num?)?.toInt() ?? products.length;

    return ProductPage(products: products, total: total);
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await dio.get('/products/category-list');
    final data = response.data;

    if (data is! List) {
      throw const FormatException('Invalid category response from server');
    }

    // Accept plain strings or {slug: ...} objects, in case the API changes
    return data
        .map((item) => item is Map ? item['slug'].toString() : item.toString())
        .toList();
  }
}
