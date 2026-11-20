import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../products/presentation/pages/product_details_page.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/promo_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Ask for the next page when the user is close to the bottom.
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<ProductBloc>().add(const ProductNextPageRequested());
    }
  }

  /// Wait until the user stops typing for 400 ms before calling the API,
  /// instead of sending a request for every letter.
  void _onSearchChanged(String value) {
    setState(() {}); // Show or hide the clear (X) button
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      context.read<ProductBloc>().add(ProductSearchChanged(value));
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {});
    context.read<ProductBloc>().add(const ProductSearchChanged(''));
  }

  void _onCategorySelected(String category) {
    // Picking a category clears the search box too
    _searchDebounce?.cancel();
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      setState(() {});
    }
    context.read<ProductBloc>().add(ProductCategorySelected(category));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ShopMate',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          // Very first load: one full-screen spinner
          if (state.status == ProductStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(state)),
              ..._buildProductSlivers(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ProductState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Text(
            'Discover products',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: PromoBanner(),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search all products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (state.categories.isNotEmpty) ...[
          CategorySelector(
            categories: ['all', ...state.categories],
            selectedCategory: state.selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  List<Widget> _buildProductSlivers(ProductState state) {
    switch (state.status) {
      case ProductStatus.initial:
      case ProductStatus.loading:
        return [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
        ];

      case ProductStatus.failure:
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 48,
                horizontal: 32,
              ),
              child: Column(
                children: [
                  Text(
                    state.errorMessage ?? 'Something went wrong.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProductBloc>().add(
                      const ProductFetchRequested(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ];

      case ProductStatus.success:
        if (state.products.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    state.query.isNotEmpty
                        ? 'No products match "${state.query}"'
                        : 'No products found',
                  ),
                ),
              ),
            ),
          ];
        }

        return [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              itemCount: state.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = state.products[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(product: product),
                      ),
                    );
                  },
                  child: ProductCard(product: product),
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: _buildFooter(state)),
        ];
    }
  }

  /// What sits under the grid: a spinner, a retry button, or "the end".
  Widget _buildFooter(ProductState state) {
    Widget child;

    if (state.isLoadingMore) {
      child = const CircularProgressIndicator(color: AppColors.primary);
    } else if (state.loadMoreFailed) {
      child = TextButton.icon(
        onPressed: () => context.read<ProductBloc>().add(
          const ProductNextPageRequested(),
        ),
        icon: const Icon(Icons.refresh),
        label: const Text('Couldn\'t load more. Tap to retry'),
      );
    } else if (state.hasReachedEnd &&
        state.products.length > ProductBloc.pageSize) {
      child = const Text(
        'You\'ve seen everything',
        style: TextStyle(color: AppColors.textSecondary),
      );
    } else {
      child = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Center(child: child),
    );
  }
}
