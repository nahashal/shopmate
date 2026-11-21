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

  /// Changes the signed-in user's name and returns the updated user.
  Future<AppUser> updateDisplayName(String name);

  /// Emails the user a link to set a new password.
  Future<void> sendPasswordResetEmail(String email);
}
