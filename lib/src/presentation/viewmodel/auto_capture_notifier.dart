import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/auto_capture_state.dart';
import 'package:my_budget/src/data/services/transaction_detection_service.dart';
import 'package:my_budget/src/providers/pending_prefill_provider.dart';
import 'package:my_budget/src/providers/transaction_detection_service_provider.dart';

/// Owns automatic capture of mobile-money transactions from Android notifications.
///
/// When the user taps a Budgeteer "add this transaction?" notification, the native
/// side holds the payload; we pull it here and publish it to [pendingPrefillProvider],
/// which the UI turns into a pre-filled add-transaction sheet. Nothing is written to
/// the database automatically — the user confirms every capture by hand.
///
/// A tapped transaction reaches us three ways, all funnelling into [_consumePrefill]:
///  - on startup (the app was cold-started by the tap),
///  - on resume (tapped while the app was backgrounded), and
///  - via the event-channel ping (tapped while the app was open).
class AutoCaptureNotifier extends AsyncNotifier<AutoCaptureState> {
  late final TransactionDetectionService _service;

  @override
  Future<AutoCaptureState> build() async {
    _service = ref.read(transactionDetectionServiceProvider);

    final subscription = _service.onDetection.listen((_) => _consumePrefill());
    final lifecycle = AppLifecycleListener(onResume: _consumePrefill);

    ref.onDispose(() {
      subscription.cancel();
      lifecycle.dispose();
    });

    final isEnabled = await _service.isListenerEnabled();

    // A cold start from a notification tap already has a payload waiting.
    await _consumePrefill();

    return AutoCaptureState(isListenerEnabled: isEnabled);
  }

  /// Sends the user to the system notification-access screen. The resume hook picks
  /// the result up, so there's nothing to await here.
  Future<void> requestListenerPermission() async {
    await _service.openListenerSettings();
  }

  /// Re-checks whether notification access is still granted.
  Future<void> refreshPermission() async {
    final isEnabled = await _service.isListenerEnabled();

    state = AsyncData(AutoCaptureState(isListenerEnabled: isEnabled));
  }

  /// Pulls a tapped transaction (if any) and hands it to the UI to pre-fill the sheet.
  Future<void> _consumePrefill() async {
    final detected = await _service.consumePrefill();

    if (detected == null) return;

    ref.read(pendingPrefillProvider.notifier).set(detected);
  }
}
