import 'package:flutter_riverpod/legacy.dart';

class PageIndexNotifier extends StateNotifier<int> {
  PageIndexNotifier() : super(0);

  void changePage(int index) {
    state = index;
  }
}

final pageIndexProvider = StateNotifierProvider<PageIndexNotifier, int>(
  (ref) => PageIndexNotifier(),
);
