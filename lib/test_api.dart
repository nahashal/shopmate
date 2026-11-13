import 'package:flutter/material.dart';

import 'core/network/dio_client.dart';
import 'features/products/data/datasources/product_remote_data_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = DioClient.createDio();

  final dataSource = ProductRemoteDataSourceImpl(dio: dio);

  try {
    final products = await dataSource.getProducts();

    print('Total products received: ${products.length}');

    for (final product in products.take(5)) {
      print('Product: ${product.title}');
      print('Price: \$${product.price}');
      print('Category: ${product.category}');
      print('-----------------------');
    }
  } catch (e) {
    print('API Error: $e');
  }
}
