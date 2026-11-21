import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;
  final bool isSubmitting;
  final String? errorMessage;

  /// A one-off success message, e.g. "Name updated".
  final String? infoMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
    this.infoMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Note: errorMessage and infoMessage are NOT kept from the old state.
  /// Leaving them out of a copyWith call clears them.
  AuthState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    String? infoMessage,
  }) {
    return AuthState(
      status: status,
      user: user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    isSubmitting,
    errorMessage,
    infoMessage,
  ];
}
