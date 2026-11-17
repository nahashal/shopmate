import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to a user's favourites (sent after login).
class FavoritesStarted extends FavoritesEvent {
  final String userId;

  const FavoritesStarted(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Stop listening and clear (sent after logout).
class FavoritesStopped extends FavoritesEvent {
  const FavoritesStopped();
}

/// Add if not a favourite, remove if it is.
class FavoriteToggled extends FavoritesEvent {
  final Product product;

  const FavoriteToggled(this.product);

  @override
  List<Object?> get props => [product];
}

/// Used inside the BLoC when Firestore sends new data.
class FavoritesUpdated extends FavoritesEvent {
  final List<Product> favorites;

  const FavoritesUpdated(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

/// Used inside the BLoC when the Firestore stream fails.
class FavoritesLoadFailed extends FavoritesEvent {
  final String message;

  const FavoritesLoadFailed(this.message);

  @override
  List<Object?> get props => [message];
}
