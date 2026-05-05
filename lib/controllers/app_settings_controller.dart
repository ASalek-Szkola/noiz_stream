import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static const String themeModeKey = 'theme_mode_v1';
  static const String playOnStartupKey = 'play_on_startup_v1';
  static const String crossfadeDurationKey = 'crossfade_duration_v1';

  ThemeMode _themeMode = ThemeMode.light;
  bool _playOnStartup = false;
  double _crossfadeDuration = 2.0;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get playOnStartup => _playOnStartup;
  double get crossfadeDuration => _crossfadeDuration;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = _themeModeFromStorage(prefs.getString(themeModeKey));
    _playOnStartup = prefs.getBool(playOnStartupKey) ?? _playOnStartup;
    _crossfadeDuration =
        (prefs.getDouble(crossfadeDurationKey) ?? _crossfadeDuration)
            .clamp(1.0, 10.0)
            .toDouble();

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setPlayOnStartup(bool value) async {
    if (_playOnStartup == value) return;
    _playOnStartup = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setCrossfadeDuration(double value, {bool persist = true}) async {
    final normalized = value.clamp(1.0, 10.0).toDouble();

    if (_crossfadeDuration == normalized) {
      if (persist) {
        await _persist();
      }
      return;
    }

    _crossfadeDuration = normalized;
    notifyListeners();

    if (persist) {
      await _persist();
    }
  }

  ThemeMode _themeModeFromStorage(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeModeKey, _themeMode.name);
    await prefs.setBool(playOnStartupKey, _playOnStartup);
    await prefs.setDouble(crossfadeDurationKey, _crossfadeDuration);
  }
}
