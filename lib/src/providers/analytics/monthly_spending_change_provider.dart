import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';

final monthlySpendingChangeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];

  final now = DateTime.now();

  final thisMonth = transactions.where(
    (t) =>
        t.type == 'expense' &&
        t.date.year == now.year &&
        t.date.month == now.month,
  );

  final lastMonthDate = DateTime(now.year, now.month - 1);

  final lastMonth = transactions.where(
    (t) =>
        t.type == 'expense' &&
        t.date.year == lastMonthDate.year &&
        t.date.month == lastMonthDate.month,
  );

  final thisMonthTotal = thisMonth.fold<double>(0, (sum, t) => sum + t.amount);

  final lastMonthTotal = lastMonth.fold<double>(0, (sum, t) => sum + t.amount);

  if (lastMonthTotal == 0) {
    return 0;
  }

  return ((lastMonthTotal - thisMonthTotal) / lastMonthTotal) * 100;
});
