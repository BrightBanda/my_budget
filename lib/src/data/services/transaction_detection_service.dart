import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:my_budget/src/data/models/detected_transaction.dart';

/// Talks to the Android notification listener.
///
/// The only place in the app that knows platform channels exist — everything above
/// this line deals in [DetectedTransaction]s.
class TransactionDetectionService {
  static const _methodChannel = MethodChannel(
    'com.example.my_budget/transactions',
  );

  static const _eventChannel = EventChannel(
    'com.example.my_budget/transactions_events',
  );

  /// Fires whenever the listener queues a new detection while the app is alive.
  /// Carries no payload — it means "drain now", and [drainPending] is the source of truth.
  Stream<void> get onDetection => _eventChannel.receiveBroadcastStream();

  /// Whether the user has granted notification access to the app.
  Future<bool> isListenerEnabled() async {
    final enabled = await _methodChannel.invokeMethod<bool>('isListenerEnabled');

    return enabled ?? false;
  }

  /// Opens the system notification-access screen. Android offers no in-app prompt
  /// for this permission, so the user has to toggle it there themselves.
  Future<void> openListenerSettings() async {
    await _methodChannel.invokeMethod<void>('openListenerSettings');
  }

  /// Pulls every queued detection and clears the native queue.
  Future<List<DetectedTransaction>> drainPending() async {
    final raw = await _methodChannel.invokeListMethod<String>('drainPending');

    if (raw == null || raw.isEmpty) return const [];

    final detections = <DetectedTransaction>[];

    for (final entry in raw) {
      try {
        detections.add(
          DetectedTransaction.fromMap(jsonDecode(entry) as Map<String, dynamic>),
        );
      } catch (_) {
        // A single malformed payload must not cost us the rest of the batch.
        continue;
      }
    }

    return detections;
  }
}
