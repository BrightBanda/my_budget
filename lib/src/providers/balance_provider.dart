import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/providers/total_expense_provider.dart';
import 'package:my_budget/src/providers/total_income_provider.dart';

final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);

  final expense = ref.watch(totalExpenseProvider);

  return income - expense;
});
