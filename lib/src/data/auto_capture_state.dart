/// State of the automatic transaction capture feature.
class AutoCaptureState {
  /// Whether the user has granted notification access. Without it the listener
  /// never runs, so nothing is ever detected or prompted.
  final bool isListenerEnabled;

  const AutoCaptureState({this.isListenerEnabled = false});

  AutoCaptureState copyWith({bool? isListenerEnabled}) {
    return AutoCaptureState(
      isListenerEnabled: isListenerEnabled ?? this.isListenerEnabled,
    );
  }
}
