import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService {
  static const String _highContrastKey = 'high_contrast_mode';
  static const String _hapticFeedbackKey = 'haptic_feedback_enabled';
  static const String _screenReaderKey = 'screen_reader_enabled';
  
  static final ValueNotifier<bool> highContrastMode = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> hapticFeedbackEnabled = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> screenReaderEnabled = ValueNotifier<bool>(true);
  
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final highContrast = prefs.getBool(_highContrastKey) ?? false;
    final hapticEnabled = prefs.getBool(_hapticFeedbackKey) ?? true;
    final screenReader = prefs.getBool(_screenReaderKey) ?? true;
    
    highContrastMode.value = highContrast;
    hapticFeedbackEnabled.value = hapticEnabled;
    screenReaderEnabled.value = screenReader;
  }
  
  static Future<void> toggleHighContrast(bool enabled) async {
    highContrastMode.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, enabled);
  }
  
  static Future<void> toggleHapticFeedback(bool enabled) async {
    hapticFeedbackEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticFeedbackKey, enabled);
  }
  
  static Future<void> toggleScreenReader(bool enabled) async {
    screenReaderEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_screenReaderKey, enabled);
  }
  
  static Future<void> announceText(String text) async {
    if (screenReaderEnabled.value) {
      // In a real implementation, we would use a package like
      // flutter_tts or a platform-specific accessibility API
      // For now, we'll just print to console in debug mode
      debugPrint('Accessibility Announcement: $text');
    }
  }
  
  static Future<void> triggerHapticFeedback(HapticFeedbackType type) async {
    if (hapticFeedbackEnabled.value && await Vibration.hasVibrator() == true) {
      switch (type) {
        case HapticFeedbackType.selection:
          if (await Vibration.hasAmplitudeControl() == true) {
            Vibration.vibrate(amplitude: 50, duration: 10);
          } else {
            Vibration.vibrate(duration: 10);
          }
          break;
        case HapticFeedbackType.impact:
          if (await Vibration.hasAmplitudeControl() == true) {
            Vibration.vibrate(amplitude: 150, duration: 50);
          } else {
            Vibration.vibrate(duration: 50);
          }
          break;
        case HapticFeedbackType.notification:
          if (await Vibration.hasAmplitudeControl() == true) {
            Vibration.vibrate(amplitude: 200, duration: 100);
          } else {
            Vibration.vibrate(duration: 100);
          }
          break;
      }
    }
  }
}

enum HapticFeedbackType {
  selection,
  impact,
  notification,
}