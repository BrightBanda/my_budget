import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';

final averageDailySpendingProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];

  final now = DateTime.now();

  final monthlyExpenses = transactions.where((t) {
    return t.type == 'expense' &&
        t.date.year == now.year &&
        t.date.month == now.month;
  });

  final totalSpent = monthlyExpenses.fold<double>(
    0,
    (sum, t) => sum + t.amount,
  );

  return totalSpent / now.day; // Days elapsed this month
});
