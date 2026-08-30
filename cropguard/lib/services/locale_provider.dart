import 'package:flutter/material.dart';
import 'user_preferences.dart';

/// Manages the app locale and notifies listeners when it changes.
/// Language changes are immediately reflected in the UI without restart.
class LocaleProvider extends ChangeNotifier {
  static final LocaleProvider _instance = LocaleProvider._internal();
  static LocaleProvider get instance => _instance;

  LocaleProvider._internal();
  factory LocaleProvider() => _instance;

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Load saved locale from SharedPreferences on app startup.
  Future<void> loadLocale() async {
    final code = await UserPreferences.getLocaleCode();
    _locale = Locale(code);
    notifyListeners();
  }

  /// Update locale and persist selection.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await UserPreferences.setLocaleCode(locale.languageCode);
    notifyListeners();
  }

  /// Supported locales list.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];
}
