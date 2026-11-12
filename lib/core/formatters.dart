import 'package:intl/intl.dart';

import 'config.dart';

final _money = NumberFormat.currency(
  symbol: AppConfig.currencySymbol,
  decimalDigits: 0,
);
final _number = NumberFormat.decimalPattern();
final _date = DateFormat.yMMMd();

String formatMoney(num amount) => _money.format(amount);
String formatKm(num km) => '${_number.format(km)} km';
String formatDate(DateTime? date) => date == null ? '' : _date.format(date);

/// Reads a date stored either as a [DateTime] or as a Firestore `Timestamp`
/// without making the models depend on Firebase.
DateTime? parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  try {
    return (value as dynamic).toDate() as DateTime;
  } catch (_) {
    return null;
  }
}
