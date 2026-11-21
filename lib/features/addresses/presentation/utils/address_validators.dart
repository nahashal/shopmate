class AddressValidators {
  static String? required(String? value, String field) {
    if ((value ?? '').trim().isEmpty) return 'Enter your $field';
    return null;
  }

  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'Enter a 10-digit phone number';
    return null;
  }

  static String? pin(String? value) {
    if (!RegExp(r'^\d{6}$').hasMatch((value ?? '').trim())) {
      return 'Enter a 6-digit PIN';
    }
    return null;
  }
}
