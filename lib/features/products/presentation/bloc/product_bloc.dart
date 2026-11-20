import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_products.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  static const int pageSize = 20;

  final GetProducts getProducts;
  final GetCategories getCategories;

  /// Goes up by one every time the category or search changes.
  /// A response that comes back after the filter has changed is ignored,
  /// so a slow "beauty" request can't overwrite newer "laptops" results.
  int _requestId = 0;

  ProductBloc({required this.getProducts, required this.getCategories})
    : super(const ProductState()) {
    on<ProductFetchRequested>(_onFetchRequested);
    on<ProductNextPageRequested>(_onNextPageRequested);
    on<ProductCategorySelected>(_onCategorySelected);
    on<ProductSearchChanged>(_onSearchChanged);
  }

  Future<void> _onFetchRequested(
    ProductFetchRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (state.categories.isEmpty) {
      try {
        final categories = await getCategories();
        emit(state.copyWith(categories: categories));
      } catch (_) {
        // Categories are a nice-to-have; products can still load without them.
      }
    }

    await _loadFirstPage(emit);
  }

  Future<void> _onCategorySelected(
    ProductCategorySelected event,
    Emitter<ProductState> emit,
  ) async {
    if (event.category == state.selectedCategory && state.query.isEmpty) {
      return;
    }

    // Picking a category clears the search
    emit(state.copyWith(selectedCategory: event.category, query: ''));
    await _loadFirstPage(emit);
  }

  Future<void> _onSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductState> emit,
  ) async {
    final query = event.query.trim();
    if (query == state.query) return;

    // Searching looks through all categories
    emit(state.copyWith(query: query, selectedCategory: 'all'));
    await _loadFirstPage(emit);
  }

  Future<void> _loadFirstPage(Emitter<ProductState> emit) async {
    final requestId = ++_requestId;
    final category = state.selectedCategory;
    final query = state.query;

    emit(
      state.copyWith(
        status: ProductStatus.loading,
        products: const [],
        hasReachedEnd: false,
        isLoadingMore: false,
        loadMoreFailed: false,
      ),
    );

    try {
      final page = await getProducts(
        limit: pageSize,
        skip: 0,
        category: category,
        query: query,
      );
      if (requestId != _requestId) return; // Filter changed meanwhile

      emit(
        state.copyWith(
          status: ProductStatus.success,
          products: page.products,
          hasReachedEnd: page.products.length >= page.total,
        ),
      );
    } catch (_) {
      if (requestId != _requestId) return;

      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: 'Could not load products. Check your connection.',
        ),
      );
    }
  }

  Future<void> _onNextPageRequested(
    ProductNextPageRequested event,
    Emitter<ProductState> emit,
  ) async {
    // Scrolling fires this many times; only one page loads at a time.
    if (state.status != ProductStatus.success ||
        state.isLoadingMore ||
        state.hasReachedEnd) {
      return;
    }

    final requestId = _requestId;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));

    try {
      final page = await getProducts(
        limit: pageSize,
        skip: state.products.length,
        category: state.selectedCategory,
        query: state.query,
      );
      if (requestId != _requestId) return;

      final products = [...state.products, ...page.products];

      emit(
        state.copyWith(
          products: products,
          isLoadingMore: false,
          hasReachedEnd:
              page.products.isEmpty || products.length >= page.total,
        ),
      );
    } catch (_) {
      if (requestId != _requestId) return;

      emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
    }
  }
}
