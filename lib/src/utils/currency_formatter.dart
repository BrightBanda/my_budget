import 'package:intl/intl.dart';
import 'package:my_budget/src/data/models/currency.dart';

/// Formats monetary amounts in the user's chosen [Currency].
///
/// The single source of truth for how money is rendered across the app. Obtain it
/// from `currencyFormatterProvider` (which rebuilds when the currency changes) rather
/// than constructing one, so every amount reacts to a currency switch at once.
class CurrencyFormatter {
  CurrencyFormatter(this.currency);

  final Currency currency;

  static final NumberFormat _whole = NumberFormat('#,##0');
  static final NumberFormat _withDecimals = NumberFormat('#,##0.00');

  /// e.g. 250000 -> "MK 250,000" (or "MK 250,000.00" with [decimals]).
  String format(num amount, {bool decimals = false}) {
    final number = (decimals ? _withDecimals : _whole).format(amount);

    return '${currency.symbol} $number';
  }

  /// A signed amount, e.g. "+MK 5,000" / "-MK 5,000".
  String formatSigned(num amount, {required bool isIncome, bool decimals = false}) {
    final sign = isIncome ? '+' : '-';

    return '$sign${format(amount, decimals: decimals)}';
  }
}

/// Kept for currency-agnostic number rendering (thousands separators, no symbol).
extension NumberFormatting on num {
  static final NumberFormat _formatter = NumberFormat('#,##0');

  /// 250000 -> 250,000
  String get formatted => _formatter.format(this);

  /// 250000.50 -> 250,000.50
  String get formattedDecimal => NumberFormat('#,##0.00').format(this);
}
