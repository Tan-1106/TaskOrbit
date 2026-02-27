import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

/// Persists and notifies locale changes across the app.
class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(_loadInitial(_prefs));

  final SharedPreferences _prefs;

  static Locale _loadInitial(SharedPreferences prefs) {
    final saved = prefs.getString(_kLocaleKey);
    if (saved == 'vi') return const Locale('vi');
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    value = locale;
    await _prefs.setString(_kLocaleKey, locale.languageCode);
  }
}
