import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';
const _supportedCodes = {'en', 'vi'};

class LocaleNotifier extends ValueNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_loadInitial(_prefs));

  /// Loads the initial locale from shared preferences or device settings.
  static Locale _loadInitial(SharedPreferences prefs) {
    final saved = prefs.getString(_kLocaleKey);

    // User already chose a language manually -> use it.
    if (saved != null && _supportedCodes.contains(saved)) return Locale(saved);

    // First launch — detect the device / system locale.
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final code = deviceLocale.languageCode;
    if (_supportedCodes.contains(code)) return Locale(code);

    // Fallback to English if device locale is not supported.
    return const Locale('en');
  }

  /// Updates the locale and saves the user's choice to shared preferences.
  Future<void> setLocale(Locale locale) async {
    value = locale;
    await _prefs.setString(_kLocaleKey, locale.languageCode);
  }
}
