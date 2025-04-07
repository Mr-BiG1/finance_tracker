import 'package:intl/intl.dart';

class FormatUtils {
  static final _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static String formatCurrency(double amount, {bool showSign = false}) {
    final sign = showSign ? (amount >= 0 ? '+' : '-') : '';
    return '$sign${_currencyFormat.format(amount.abs())}';
  }
}
