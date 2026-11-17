import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Emits the current user whenever they log in or out.
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}
