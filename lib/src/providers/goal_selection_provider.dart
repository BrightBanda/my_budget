import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/presentation/viewmodel/goal_selection_notifier.dart';

final goalSelectionProvider =
    NotifierProvider<GoalSelectionNotifier, Set<String>>(
      GoalSelectionNotifier.new,
    );
