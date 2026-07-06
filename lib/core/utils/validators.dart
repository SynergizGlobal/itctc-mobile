class Validators {
  Validators._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? numeric(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value.trim()) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  static String? requiredNumeric(String? value, {String fieldName = 'This field'}) {
    final req = required(value, fieldName: fieldName);
    if (req != null) return req;
    return numeric(value, fieldName: fieldName);
  }
}

double? parseDouble(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return double.tryParse(value.trim());
}

String formatValue(double? value, {String empty = '—'}) {
  if (value == null) return empty;
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}
