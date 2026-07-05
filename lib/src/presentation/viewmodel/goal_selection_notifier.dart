import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/services/database_service.dart';
import 'package:my_budget/src/providers/database_service_provider.dart';
import 'package:my_budget/src/providers/goals_provider.dart';

class GoalSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final updated = Set<String>.from(state);

    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }

    state = updated;
  }

  void clear() {
    state = {};
  }

  void toggleAll(List<String> ids) {
    if (state.length == ids.length && ids.isNotEmpty) {
      state = {};
    } else {
      state = ids.toSet();
    }
  }
}
