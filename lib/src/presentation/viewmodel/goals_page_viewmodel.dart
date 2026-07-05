import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/savings_goal.dart';
import 'package:my_budget/src/data/models/transaction.dart';
import 'package:my_budget/src/data/services/database_service.dart';
import 'package:my_budget/src/providers/database_service_provider.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';

class GoalsNotifier extends AsyncNotifier<List<SavingGoal>> {
  late final DatabaseService _db;
  @override
  Future<List<SavingGoal>> build() async {
    _db = ref.read(databaseServiceProvider);
    return _loadGoals();
  }

  Future<List<SavingGoal>> _loadGoals() async {
    final db = ref.read(databaseServiceProvider);
    return db.getGoals();
  }

  Future<void> refreshGoals() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return _loadGoals();
    });
  }

  Future<void> addGoal(SavingGoal goal) async {
    final db = ref.read(databaseServiceProvider);

    await db.insertGoal(goal);

    await refreshGoals();
  }

  Future<void> updateGoal(SavingGoal goal) async {
    final db = ref.read(databaseServiceProvider);

    await db.updateGoal(goal);

    await refreshGoals();
  }

  Future<void> deleteGoal(String id) async {
    final db = ref.read(databaseServiceProvider);

    await db.deleteGoal(id);

    await refreshGoals();
  }

  Future<void> deleteGoals(List<String> ids) async {
    final db = ref.read(databaseServiceProvider);
    for (final id in ids) {
      await db.deleteGoal(id);
    }
    await refreshGoals();
  }

  Future<void> addFunds(
    String goalId,
    double amount, {
    bool deductFromBalance = true,
  }) async {
    final goal = await _db.getGoal(goalId);

    if (goal == null) return;

    final updatedGoal = goal.copyWith(
      currentAmount: goal.currentAmount + amount,
    );

    await _db.updateGoal(updatedGoal);

    if (deductFromBalance) {
      final transaction = BudgetTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Savings: ${goal.title}',
        type: 'expense',
        category: 'Savings',
        amount: amount,
        date: DateTime.now(),
      );

      await _db.insertTransaction(transaction);

      ref.read(transactionsProvider.notifier).refreshTransactions();
    }

    final updatedGoals = await _db.getGoals();

    state = AsyncData(updatedGoals);
  }
}
