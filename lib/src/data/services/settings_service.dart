import 'package:shared_preferences/shared_preferences.dart';

/// Persists user preferences via [SharedPreferences].
///
/// One place for every simple app setting. Add a typed getter/setter pair per new
/// preference — keys live here so they never drift across the codebase.
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _currencyCodeKey = 'settings.currency_code';

  String? getCurrencyCode() => _prefs.getString(_currencyCodeKey);

  Future<void> setCurrencyCode(String code) =>
      _prefs.setString(_currencyCodeKey, code);
}
