import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/auto_capture_state.dart';
import 'package:my_budget/src/presentation/viewmodel/auto_capture_notifier.dart';

final autoCaptureProvider =
    AsyncNotifierProvider<AutoCaptureNotifier, AutoCaptureState>(
      AutoCaptureNotifier.new,
    );
