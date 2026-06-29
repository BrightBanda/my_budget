import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';

final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];

  return transactions
      .where((t) => t.type == 'income')
      .fold(0, (sum, t) => sum + t.amount);
});
