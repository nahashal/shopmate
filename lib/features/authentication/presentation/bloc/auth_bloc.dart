import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthDisplayNameUpdateRequested>(_onDisplayNameUpdateRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    // Listen to Firebase for as long as the app is running.
    await emit.forEach<AppUser?>(
      _authRepository.authStateChanges,
      onData: (user) => _stateFor(user),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(_stateFor(user));
    } on AuthFailure catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      final user = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(_stateFor(user));
    } on AuthFailure catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    // The authStateChanges stream will emit null → unauthenticated.
  }

  Future<void> _onDisplayNameUpdateRequested(
    AuthDisplayNameUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      final user = await _authRepository.updateDisplayName(event.name);
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
          infoMessage: 'Name updated',
        ),
      );
    } on AuthFailure catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(
        state.copyWith(
          isSubmitting: false,
          infoMessage: 'Password reset link sent to ${event.email}',
        ),
      );
    } on AuthFailure catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  AuthState _stateFor(AppUser? user) {
    return user == null
        ? const AuthState(status: AuthStatus.unauthenticated)
        : AuthState(status: AuthStatus.authenticated, user: user);
  }
}
