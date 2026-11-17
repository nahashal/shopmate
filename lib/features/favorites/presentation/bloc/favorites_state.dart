import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';

class FavoritesState extends Equatable {
  final List<Product> favorites;
  final bool isLoading;
  final String? errorMessage;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  bool isFavorite(int productId) {
    return favorites.any((product) => product.id == productId);
  }

  int get count => favorites.length;

  FavoritesState copyWith({
    List<Product>? favorites,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [favorites, isLoading, errorMessage];
}
