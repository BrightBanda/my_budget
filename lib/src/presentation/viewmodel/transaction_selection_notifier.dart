import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  bool get isSelecting => state.isNotEmpty;

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
