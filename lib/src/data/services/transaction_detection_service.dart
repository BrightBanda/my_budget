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

  /// Fires when a notification is tapped while the app is already open. Carries no
  /// payload — it means "a tapped transaction is waiting, call [consumePrefill]".
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

  /// Returns the transaction from the most recently tapped notification, or null if
  /// none is waiting. Reading it clears it on the native side.
  Future<DetectedTransaction?> consumePrefill() async {
    final raw = await _methodChannel.invokeMethod<String>('consumePrefill');

    if (raw == null || raw.isEmpty) return null;

    try {
      return DetectedTransaction.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
