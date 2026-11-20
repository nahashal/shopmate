import 'package:equatable/equatable.dart';

import 'product.dart';

/// One page of products from the API, plus how many exist in total.
class ProductPage extends Equatable {
  final List<Product> products;
  final int total;

  const ProductPage({required this.products, required this.total});

  @override
  List<Object?> get props => [products, total];
}
