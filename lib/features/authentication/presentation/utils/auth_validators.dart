class AuthValidators {
  static String? name(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Enter your name';
    return null;
  }

  static String? email(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Enter your email';

    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(email)) return 'Enter a valid email';

    return null;
  }

  static String? required(String? value) {
    if ((value ?? '').isEmpty) return 'Enter your password';
    return null;
  }

  static String? newPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Create a password';
    if (value!.length < 6) return 'Use at least 6 characters';
    return null;
  }
}
