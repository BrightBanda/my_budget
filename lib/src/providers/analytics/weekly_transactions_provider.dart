import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';

final weeklyTransactionsProvider = Provider<int>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];

  final now = DateTime.now();

  // Monday is the first day of the week
  final startOfWeek = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: now.weekday - 1));

  final endOfWeek = startOfWeek.add(const Duration(days: 7));

  return transactions.where((transaction) {
    return transaction.date.isAfter(
          startOfWeek.subtract(const Duration(milliseconds: 1)),
        ) &&
        transaction.date.isBefore(endOfWeek);
  }).length;
});
