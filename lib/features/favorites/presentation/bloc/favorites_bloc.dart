import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _repository;

  StreamSubscription<List<Product>>? _subscription;
  String? _userId;

  FavoritesBloc(this._repository) : super(const FavoritesState()) {
    on<FavoritesStarted>(_onStarted);
    on<FavoritesStopped>(_onStopped);
    on<FavoriteToggled>(_onToggled);
    on<FavoritesUpdated>(
      (event, emit) => emit(FavoritesState(favorites: event.favorites)),
    );
    on<FavoritesLoadFailed>(
      (event, emit) =>
          emit(state.copyWith(isLoading: false, errorMessage: event.message)),
    );
  }

  Future<void> _onStarted(
    FavoritesStarted event,
    Emitter<FavoritesState> emit,
  ) async {
    // Stop any previous user's stream first
    await _subscription?.cancel();
    _userId = event.userId;

    emit(const FavoritesState(isLoading: true));

    _subscription = _repository
        .watchFavorites(event.userId)
        .listen(
          (favorites) => add(FavoritesUpdated(favorites)),
          onError: (_) =>
              add(const FavoritesLoadFailed('Could not load your favourites.')),
        );
  }

  Future<void> _onStopped(
    FavoritesStopped event,
    Emitter<FavoritesState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = null;
    _userId = null;
    emit(const FavoritesState());
  }

  Future<void> _onToggled(
    FavoriteToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      if (state.isFavorite(event.product.id)) {
        await _repository.removeFavorite(userId, event.product.id);
      } else {
        await _repository.addFavorite(userId, event.product);
      }
      // No emit needed: the Firestore stream sends the updated list.
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Could not update favourites. Check your connection.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
