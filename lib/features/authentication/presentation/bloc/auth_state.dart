import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;
  final bool isSubmitting;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Note: errorMessage is NOT kept from the old state.
  /// Leaving it out of a copyWith call clears it.
  AuthState copyWith({bool? isSubmitting, String? errorMessage}) {
    return AuthState(
      status: status,
      user: user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, isSubmitting, errorMessage];
}
