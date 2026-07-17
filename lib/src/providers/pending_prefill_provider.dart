import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/detected_transaction.dart';

/// The detected transaction waiting to pre-fill the add-transaction sheet, or null.
///
/// [AutoCaptureNotifier] sets this when a notification is tapped; the UI watches it,
/// opens the sheet, then calls [clear]. A plain holder — no logic beyond hand-off.
class PendingPrefillNotifier extends Notifier<DetectedTransaction?> {
  @override
  DetectedTransaction? build() => null;

  void set(DetectedTransaction transaction) => state = transaction;

  void clear() => state = null;
}

final pendingPrefillProvider =
    NotifierProvider<PendingPrefillNotifier, DetectedTransaction?>(
      PendingPrefillNotifier.new,
    );
