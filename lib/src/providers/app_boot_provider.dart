import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while the app is showing its initial loading skeletons, flipping to false
/// after a short warm-up. Watched once at the router so it runs a single time per launch.
class AppBootNotifier extends Notifier<bool> {
  static const _splashDuration = Duration(seconds: 2);

  @override
  bool build() {
    Future.delayed(_splashDuration, () => state = false);

    return true;
  }
}

final appBootProvider = NotifierProvider<AppBootNotifier, bool>(
  AppBootNotifier.new,
);
