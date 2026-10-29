import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  symbol: r'$',
  decimalDigits: 2,
  locale: 'en_US',
);

final _compactNumber = NumberFormat.compact(locale: 'en_US');

String formatPrice(double value) => _currency.format(value);

String formatCount(int value) => _compactNumber.format(value);

String formatRating(double value) => value.toStringAsFixed(1);
