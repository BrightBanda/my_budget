import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';

final monthlyIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];

  final now = DateTime.now();

  return transactions
      .where(
        (t) =>
            t.type == 'income' &&
            t.date.year == now.year &&
            t.date.month == now.month,
      )
      .fold<double>(0, (sum, t) => sum + t.amount);
});
