import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'app_language';
  static const String _rtlKey = 'rtl_mode';
  
  static final ValueNotifier<Locale> appLocale = ValueNotifier<Locale>(const Locale('en'));
  static final ValueNotifier<bool> isRtl = ValueNotifier<bool>(false);
  
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];
  
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    final rtlMode = prefs.getBool(_rtlKey) ?? false;
    
    appLocale.value = Locale(languageCode);
    isRtl.value = rtlMode;
  }
  
  static Future<void> updateLanguage(String languageCode) async {
    appLocale.value = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    // Update RTL mode based on language
    final rtlLanguages = ['ar', 'he', 'fa', 'ur']; // Arabic, Hebrew, Farsi, Urdu
    final newRtl = rtlLanguages.contains(languageCode);
    isRtl.value = newRtl;
    await prefs.setBool(_rtlKey, newRtl);
  }
  
  static Future<void> toggleRtl(bool rtl) async {
    isRtl.value = rtl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rtlKey, rtl);
  }
  
  static TextDirection getTextDirection() {
    return isRtl.value ? TextDirection.rtl : TextDirection.ltr;
  }
}