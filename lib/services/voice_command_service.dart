import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

class VoiceCommandService {
  static const String _voiceCommandsKey = 'voice_commands_enabled';
  
  static final ValueNotifier<bool> voiceCommandsEnabled = ValueNotifier<bool>(false);
  static final stt.SpeechToText _speech = stt.SpeechToText();
  
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_voiceCommandsKey) ?? false;
    voiceCommandsEnabled.value = enabled;
  }
  
  static Future<void> toggleVoiceCommands(bool enabled) async {
    voiceCommandsEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voiceCommandsKey, enabled);
  }
  
  static Future<bool> initializeSpeech() async {
    if (!voiceCommandsEnabled.value) return false;
    
    try {
      final available = await _speech.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
        onStatus: (status) => debugPrint('Speech recognition status: $status'),
      );
      return available;
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      return false;
    }
  }
  
  static void startListening(Function(String) onResult) {
    if (!voiceCommandsEnabled.value) return;
    
    _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US', // Could be made dynamic based on app language
    );
  }
  
  static void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }
  
  // Parse voice commands to extract reminder details
  static Map<String, dynamic> parseReminderCommand(String command) {
    final result = <String, dynamic>{};
    
    // Simple parsing logic - in a real app, this would be more sophisticated
    // Example: "Add a reminder for 3 PM about feeding the cat"
    final lowerCommand = command.toLowerCase();
    
    // Extract title (what comes after "about")
    final aboutIndex = lowerCommand.indexOf('about');
    if (aboutIndex != -1) {
      final title = command.substring(aboutIndex + 6).trim();
      result['title'] = title.isNotEmpty ? title : 'Voice reminder';
    } else {
      result['title'] = 'Voice reminder';
    }
    
    // Extract time (simple approach - look for common time patterns)
    if (lowerCommand.contains('3 pm') || lowerCommand.contains('three pm')) {
      result['time'] = '15:00';
    } else if (lowerCommand.contains('9 am') || lowerCommand.contains('nine am')) {
      result['time'] = '09:00';
    } else {
      // Default to current time + 1 hour
      final now = DateTime.now();
      final oneHourLater = now.add(const Duration(hours: 1));
      result['time'] = '${oneHourLater.hour}:${oneHourLater.minute.toString().padLeft(2, '0')}';
    }
    
    result['description'] = command;
    
    return result;
  }
}