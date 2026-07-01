import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/savings_goal.dart';
import 'package:my_budget/src/presentation/viewmodel/goals_page_viewmodel.dart';

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<SavingGoal>>(
  GoalsNotifier.new,
);
