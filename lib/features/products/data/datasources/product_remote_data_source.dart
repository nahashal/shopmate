import 'package:dio/dio.dart';

import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({int limit = 20, int skip = 0});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts({int limit = 20, int skip = 0}) async {
    final response = await dio.get(
      '/products',
      queryParameters: {'limit': limit, 'skip': skip},
    );

    final data = response.data;

    if (data is! Map || data['products'] is! List) {
      throw const FormatException('Invalid product response from server');
    }

    final products = data['products'] as List;

    return products.map((product) {
      return ProductModel.fromJson(Map<String, dynamic>.from(product as Map));
    }).toList();
  }
}
