import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/services/settings_service.dart';

/// The live [SharedPreferences] instance, resolved once at startup and injected
/// via a ProviderScope override in main(). Reading it before the override is set
/// is a programming error, hence the throw.
final sharedPreferencesProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});
