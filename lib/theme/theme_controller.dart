import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
  static final ValueNotifier<Color> seedColor = ValueNotifier<Color>(Colors.teal);
  static final ValueNotifier<bool> useMaterial3 = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> use24HourTime = ValueNotifier<bool>(false);
  static final ValueNotifier<double> textScaleFactor = ValueNotifier<double>(1.0);

  static const _keyThemeMode = 'theme_mode';
  static const _keySeedColor = 'seed_color';
  static const _keyUseMaterial3 = 'use_material3';
  static const _keyUse24Hour = 'use_24h';
  static const _keyTextScale = 'text_scale';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_keyThemeMode);
    final colorValue = prefs.getInt(_keySeedColor);
    final material3 = prefs.getBool(_keyUseMaterial3);
    final use24h = prefs.getBool(_keyUse24Hour);
    final scale = prefs.getDouble(_keyTextScale);

    if (modeStr != null) {
      switch (modeStr) {
        case 'dark':
          themeMode.value = ThemeMode.dark;
          break;
        case 'light':
          themeMode.value = ThemeMode.light;
          break;
        default:
          themeMode.value = ThemeMode.system;
      }
    }

    if (colorValue != null) {
      seedColor.value = Color(colorValue);
    }
    if (material3 != null) {
      useMaterial3.value = material3;
    }
    if (use24h != null) {
      use24HourTime.value = use24h;
    }
    if (scale != null && scale > 0) {
      textScaleFactor.value = scale;
    }
  }

  static Future<void> update({required ThemeMode mode, required Color color, bool? material3, bool? use24h, double? textScale}) async {
    themeMode.value = mode;
    seedColor.value = color;
    if (material3 != null) useMaterial3.value = material3;
    if (use24h != null) use24HourTime.value = use24h;
    if (textScale != null && textScale > 0) textScaleFactor.value = textScale;
    final prefs = await SharedPreferences.getInstance();
    final modeStr = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    await prefs.setString(_keyThemeMode, modeStr);
    await prefs.setInt(_keySeedColor, color.value);
    if (material3 != null) await prefs.setBool(_keyUseMaterial3, material3);
    if (use24h != null) await prefs.setBool(_keyUse24Hour, use24h);
    if (textScale != null && textScale > 0) await prefs.setDouble(_keyTextScale, textScale);
  }
}
