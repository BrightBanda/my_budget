import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/auto_capture_state.dart';
import 'package:my_budget/src/data/models/detected_transaction.dart';
import 'package:my_budget/src/data/services/transaction_detection_service.dart';
import 'package:my_budget/src/providers/goals_provider.dart';
import 'package:my_budget/src/providers/transaction_detection_service_provider.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';

/// Owns automatic capture of mobile-money transactions from Android notifications.
///
/// Detections reach us two ways and both funnel into [syncNow]:
///  - a live ping on the event channel while the app is open, and
///  - a drain on resume, covering everything queued while the app was closed.
///
/// The native queue is the source of truth, so the two paths can overlap harmlessly.
class AutoCaptureNotifier extends AsyncNotifier<AutoCaptureState> {
  late final TransactionDetectionService _service;

  /// Guards against a resume and an event-channel ping draining at the same time.
  bool _isSyncing = false;

  @override
  Future<AutoCaptureState> build() async {
    _service = ref.read(transactionDetectionServiceProvider);

    final subscription = _service.onDetection.listen((_) => syncNow());
    final lifecycle = AppLifecycleListener(onResume: syncNow);

    ref.onDispose(() {
      subscription.cancel();
      lifecycle.dispose();
    });

    final isEnabled = await _service.isListenerEnabled();

    if (!isEnabled) return const AutoCaptureState(isListenerEnabled: false);

    return AutoCaptureState(
      isListenerEnabled: true,
      lastImportedCount: await _importPending(),
      lastSyncAt: DateTime.now(),
    );
  }

  /// Sends the user to the system notification-access screen. The resume hook picks
  /// the result up, so there's nothing to await here.
  Future<void> requestListenerPermission() async {
    await _service.openListenerSettings();
  }

  /// Re-checks permission and imports anything queued.
  Future<void> syncNow() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final isEnabled = await _service.isListenerEnabled();

      if (!isEnabled) {
        state = const AsyncData(AutoCaptureState(isListenerEnabled: false));
        return;
      }

      state = await AsyncValue.guard(() async {
        return AutoCaptureState(
          isListenerEnabled: true,
          lastImportedCount: await _importPending(),
          lastSyncAt: DateTime.now(),
        );
      });
    } finally {
      _isSyncing = false;
    }
  }

  /// Drains the native queue into the database. Returns how many detections landed.
  Future<int> _importPending() async {
    final detections = await _service.drainPending();

    if (detections.isEmpty) return 0;

    final transactions = detections
        .expand((detection) => detection.toBudgetTransactions())
        .toList();

    await ref.read(transactionsProvider.notifier).addTransactions(transactions);

    // Goals surface a live balance, so they have to see the new spend too.
    ref.invalidate(goalsProvider);

    return detections.length;
  }
}
