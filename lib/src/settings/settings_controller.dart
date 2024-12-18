import 'package:flutter/material.dart';
import '../services/locale_service.dart';
import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  late Locale _locale;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();

    // Carrega o locale baseado na localização
    _locale = await LocaleService.getDeviceLocale();

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateLocale(Locale newLocale) async {
    if (newLocale == _locale) return;

    _locale = newLocale;
    notifyListeners();
  }
}
