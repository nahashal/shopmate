import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  /// Status of the first page for the current category/search.
  final ProductStatus status;
  final List<Product> products;
  final List<String> categories;
  final String selectedCategory;
  final String query;

  /// True once every product for the current filter is loaded.
  final bool hasReachedEnd;

  /// True while the next page is loading (spinner under the grid).
  final bool isLoadingMore;

  /// True if loading the next page failed (shows a retry button).
  final bool loadMoreFailed;

  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategory = 'all',
    this.query = '',
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.errorMessage,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    List<String>? categories,
    String? selectedCategory,
    String? query,
    bool? hasReachedEnd,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      query: query ?? this.query,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    categories,
    selectedCategory,
    query,
    hasReachedEnd,
    isLoadingMore,
    loadMoreFailed,
    errorMessage,
  ];
}
