import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// First load (and "Retry"): loads categories if needed, then page 1.
class ProductFetchRequested extends ProductEvent {
  const ProductFetchRequested();
}

/// Sent when the user scrolls near the bottom.
class ProductNextPageRequested extends ProductEvent {
  const ProductNextPageRequested();
}

class ProductCategorySelected extends ProductEvent {
  final String category;

  const ProductCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class ProductSearchChanged extends ProductEvent {
  final String query;

  const ProductSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
