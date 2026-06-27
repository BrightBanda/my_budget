import 'package:my_budget/src/data/models/transaction.dart';

class BudgetTransactionState {
  final List<BudgetTransaction> budgettransactions;
  final bool isLoading;
  final String? error;

  const BudgetTransactionState({
    this.budgettransactions = const [],
    this.isLoading = false,
    this.error,
  });

  BudgetTransactionState copyWith({
    List<BudgetTransaction>? budgettransactions,
    bool? isLoading,
    String? error,
  }) {
    return BudgetTransactionState(
      budgettransactions: budgettransactions ?? this.budgettransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
