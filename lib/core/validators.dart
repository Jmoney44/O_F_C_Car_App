/// Form field validators. Each returns an error message, or null when valid.
abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _phone = RegExp(r'^\+?[0-9 ()-]{7,20}$');

  static String? required(String? value, [String field = 'This field']) {
    return (value == null || value.trim().isEmpty)
        ? '$field is required'
        : null;
  }

  static String? email(String? value) {
    final missing = required(value, 'Email');
    if (missing != null) return missing;
    return _email.hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return value.length < 8 ? 'Use at least 8 characters' : null;
  }

  static String? phone(String? value) {
    final missing = required(value, 'Phone number');
    if (missing != null) return missing;
    return _phone.hasMatch(value!.trim()) ? null : 'Enter a valid phone number';
  }

  static String? positiveInt(String? value, [String field = 'This field']) {
    final missing = required(value, field);
    if (missing != null) return missing;
    final number = int.tryParse(value!.replaceAll(',', '').trim());
    return (number == null || number <= 0) ? 'Enter a number above zero' : null;
  }

  static String? nonNegativeInt(String? value, [String field = 'This field']) {
    final missing = required(value, field);
    if (missing != null) return missing;
    final number = int.tryParse(value!.replaceAll(',', '').trim());
    return (number == null || number < 0) ? 'Enter a valid number' : null;
  }

  static String? year(String? value) {
    final missing = required(value, 'Year');
    if (missing != null) return missing;
    final number = int.tryParse(value!.trim());
    final max = DateTime.now().year + 1;
    return (number == null || number < 1950 || number > max)
        ? 'Enter a year between 1950 and $max'
        : null;
  }
}

int parseInt(String value) => int.parse(value.replaceAll(',', '').trim());
