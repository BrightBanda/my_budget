import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/currency_provider.dart';
import 'package:my_budget/src/utils/currency_formatter.dart';

/// The formatter every money-displaying widget should watch. Rebuilds whenever the
/// selected currency changes, so a currency switch reformats the whole app at once.
final currencyFormatterProvider = Provider<CurrencyFormatter>((ref) {
  return CurrencyFormatter(ref.watch(currencyProvider));
});
