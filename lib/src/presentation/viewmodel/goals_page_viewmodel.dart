import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/savings_goal.dart';
import 'package:my_budget/src/providers/database_service_provider.dart';

class GoalsNotifier extends AsyncNotifier<List<SavingGoal>> {
  @override
  Future<List<SavingGoal>> build() async {
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

  Future<void> addFunds(String goalId, double amount) async {
    final db = ref.read(databaseServiceProvider);

    final goal = await db.getGoal(goalId);

    if (goal == null) return;

    final updatedGoal = goal.copyWith(
      currentAmount: goal.currentAmount + amount,
    );

    await db.updateGoal(updatedGoal);

    await refreshGoals();
  }
}
