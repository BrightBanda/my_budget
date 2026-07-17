/// State of the automatic transaction capture feature.
class AutoCaptureState {
  /// Whether the user has granted notification access. Without it the listener
  /// never runs and nothing is ever captured.
  final bool isListenerEnabled;

  /// How many detections the most recent sync imported. Zero means "synced,
  /// nothing new".
  final int lastImportedCount;

  /// When the last sync completed. Lets the view tell two separate imports apart
  /// even when both happened to import the same number of transactions.
  final DateTime? lastSyncAt;

  const AutoCaptureState({
    this.isListenerEnabled = false,
    this.lastImportedCount = 0,
    this.lastSyncAt,
  });

  AutoCaptureState copyWith({
    bool? isListenerEnabled,
    int? lastImportedCount,
    DateTime? lastSyncAt,
  }) {
    return AutoCaptureState(
      isListenerEnabled: isListenerEnabled ?? this.isListenerEnabled,
      lastImportedCount: lastImportedCount ?? this.lastImportedCount,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}
