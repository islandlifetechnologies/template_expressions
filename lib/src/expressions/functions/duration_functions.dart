import 'package:template_expressions/template_expressions.dart';

/// Class that contains functions related to creating Durations.
class DurationFunctions {
  const DurationFunctions._();

  /// The functions related to the Duration creation
  static final functions = {
    'Duration': (value, [hours, minutes, seconds, milliseconds]) =>
        (hours != null ||
            minutes != null ||
            seconds != null ||
            milliseconds != null)
        ? Duration(
            days: maybeParseInt(value) ?? 0,
            hours: maybeParseInt(hours) ?? 0,
            minutes: maybeParseInt(minutes) ?? 0,
            seconds: maybeParseInt(seconds) ?? 0,
            milliseconds: maybeParseInt(milliseconds) ?? 0,
          )
        : value is Map
        ? Duration(
            days: maybeParseInt(value['days']) ?? 0,
            hours: maybeParseInt(value['hours']) ?? 0,
            minutes: maybeParseInt(value['minutes']) ?? 0,
            seconds: maybeParseInt(value['seconds']) ?? 0,
            milliseconds: maybeParseInt(value['milliseconds']) ?? 0,
          )
        : value is List
        ? Duration(
            days: maybeParseInt(value.isNotEmpty ? value[0] : null) ?? 0,
            hours: maybeParseInt(value.length > 1 ? value[1] : null) ?? 0,
            minutes: maybeParseInt(value.length > 2 ? value[2] : null) ?? 0,
            seconds: maybeParseInt(value.length > 3 ? value[3] : null) ?? 0,
            milliseconds:
                maybeParseInt(value.length > 4 ? value[4] : null) ?? 0,
          )
        : value is String || value is num
        ? maybeParseDurationFromMillis(value)!
        : throw Exception(
            '[Duration]: expected [value] to be a Map, a List, a String, or a num but encountered: ${value?.runtimeType}',
          ),
    'days': (value) => Duration(hours: maybeParseInt(value)! * 24),
    'hours': (value) => Duration(minutes: maybeParseInt(value)!),
    'milliseconds': (value) => Duration(milliseconds: maybeParseInt(value)!),
    'minutes': (value) => Duration(minutes: maybeParseInt(value)!),
    'seconds': (value) => Duration(seconds: maybeParseInt(value)!),
  };
}
