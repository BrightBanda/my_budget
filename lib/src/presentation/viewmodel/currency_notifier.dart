import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/currency.dart';
import 'package:my_budget/src/providers/settings_service_provider.dart';

/// Holds the user's chosen display currency, persisted across restarts.
///
/// Loads synchronously from [SettingsService] (SharedPreferences is already resolved
/// at startup), defaulting to Malawi. Selecting a currency writes it back.
class CurrencyNotifier extends Notifier<Currency> {
  @override
  Currency build() {
    final settings = ref.read(sharedPreferencesProvider);

    return Currency.fromCode(settings.getCurrencyCode());
  }

  void select(Currency currency) {
    state = currency;

    ref.read(sharedPreferencesProvider).setCurrencyCode(currency.code);
  }
}
