bool? maybeParseBool(dynamic value) {
  bool? result;

  if (value != null) {
    if (value is bool) {
      result = value;
    } else if (value is String) {
      final lower = value.toLowerCase();
      result = lower == 'true' || lower == 'yes';
    } else {
      result = maybeParseInt(value) == 1;
    }
  }

  return result;
}

double? maybeParseDouble(dynamic value, [double? defaultValue]) {
  double? result;
  try {
    if (value is String) {
      if (value.toLowerCase() == 'infinity') {
        result = double.infinity;
      } else if (value.startsWith('0x') == true) {
        result = int.tryParse(value.substring(2), radix: 16)?.toDouble();
      } else {
        result = double.tryParse(value);
      }
    } else if (value is num) {
      result = value.toDouble();
    }
  } catch (_) {
    // no-op
  }

  return result ?? defaultValue;
}

int? maybeParseInt(dynamic value, [double? defaultValue]) =>
    maybeParseDouble(value, defaultValue)?.toInt();

Duration? maybeParseDurationFromMillis(dynamic value) {
  final millis = value is Duration
      ? value.inMilliseconds
      : maybeParseInt(value);

  return millis == null ? null : Duration(milliseconds: millis);
}

bool parseBool(dynamic value, {bool whenNull = false}) {
  final result = maybeParseBool(value) ?? whenNull;

  return result;
}

double parseDouble(dynamic value) {
  double? result;
  try {
    if (value is String) {
      if (value.toLowerCase() == 'infinity') {
        result = double.infinity;
      } else if (value.startsWith('0x') == true) {
        result = int.tryParse(value.substring(2), radix: 16)?.toDouble();
      } else {
        result = double.tryParse(value);
      }
    } else if (value is num) {
      result = value.toDouble();
    }
  } catch (_) {
    // no-op
  }

  if (result == null) {
    throw Exception(
      'Non-nullable parseDouble was called but null was encountered',
    );
  }

  return result;
}

Duration parseDurationFromMillis(dynamic value) {
  final result = value is Duration ? value.inMilliseconds : parseInt(value);

  return Duration(milliseconds: result);
}

int parseInt(dynamic value) => parseDouble(value).toInt();
