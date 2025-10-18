import 'package:flutter/material.dart';
import 'reminder_category.dart';

/// Priority levels for notifications
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// Extension for NotificationPriority
extension NotificationPriorityExtension on NotificationPriority {
  /// Display name for priority
  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  /// Icon for priority level
  IconData get icon {
    switch (this) {
      case NotificationPriority.low:
        return Icons.arrow_downward_rounded;
      case NotificationPriority.normal:
        return Icons.notifications_outlined;
      case NotificationPriority.high:
        return Icons.arrow_upward_rounded;
      case NotificationPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for priority level
  Color get color {
    switch (this) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  /// Android importance mapping
  int get androidImportance {
    switch (this) {
      case NotificationPriority.low:
        return 2; // IMPORTANCE_LOW
      case NotificationPriority.normal:
        return 3; // IMPORTANCE_DEFAULT
      case NotificationPriority.high:
        return 4; // IMPORTANCE_HIGH
      case NotificationPriority.urgent:
        return 5; // IMPORTANCE_MAX
    }
  }
}

/// Available notification sounds
enum NotificationSound {
  defaultSound,
  bark,
  meow,
  chirp,
  gentle,
  urgent,
  silent,
}

/// Extension for NotificationSound
extension NotificationSoundExtension on NotificationSound {
  /// Display name for sound
  String get displayName {
    switch (this) {
      case NotificationSound.defaultSound:
        return 'Default';
      case NotificationSound.bark:
        return 'Bark';
      case NotificationSound.meow:
        return 'Meow';
      case NotificationSound.chirp:
        return 'Chirp';
      case NotificationSound.gentle:
        return 'Gentle';
      case NotificationSound.urgent:
        return 'Urgent';
      case NotificationSound.silent:
        return 'Silent';
    }
  }

  /// Android sound resource name
  String get resourceName {
    switch (this) {
      case NotificationSound.defaultSound:
        return 'default';
      case NotificationSound.bark:
        return 'bark';
      case NotificationSound.meow:
        return 'meow';
      case NotificationSound.chirp:
        return 'chirp';
      case NotificationSound.gentle:
        return 'gentle';
      case NotificationSound.urgent:
        return 'urgent';
      case NotificationSound.silent:
        return '';
    }
  }

  /// Icon for sound
  IconData get icon {
    switch (this) {
      case NotificationSound.defaultSound:
        return Icons.volume_up_rounded;
      case NotificationSound.bark:
        return Icons.pets_rounded;
      case NotificationSound.meow:
        return Icons.favorite_rounded;
      case NotificationSound.chirp:
        return Icons.music_note_rounded;
      case NotificationSound.gentle:
        return Icons.volume_down_rounded;
      case NotificationSound.urgent:
        return Icons.notification_important_rounded;
      case NotificationSound.silent:
        return Icons.volume_off_rounded;
    }
  }
}

/// Configuration for notifications per category
class NotificationConfig {
  final ReminderCategory category;
  final NotificationSound sound;
  final NotificationPriority priority;
  final bool vibrate;
  final int? advanceMinutes; // Notify X minutes before
  final bool enableLED;
  final Color? ledColor;

  const NotificationConfig({
    required this.category,
    this.sound = NotificationSound.defaultSound,
    this.priority = NotificationPriority.normal,
    this.vibrate = true,
    this.advanceMinutes,
    this.enableLED = true,
    this.ledColor,
  });

  /// Get default config for a category
  static NotificationConfig defaultForCategory(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.medication:
      case ReminderCategory.vetVisit:
        return NotificationConfig(
          category: category,
          sound: NotificationSound.urgent,
          priority: NotificationPriority.high,
          advanceMinutes: 30,
        );
      case ReminderCategory.feeding:
        return NotificationConfig(
          category: category,
          sound: NotificationSound.gentle,
          priority: NotificationPriority.normal,
          advanceMinutes: 15,
        );
      case ReminderCategory.walking:
        return NotificationConfig(
          category: category,
          sound: NotificationSound.chirp,
          priority: NotificationPriority.normal,
        );
      default:
        return NotificationConfig(
          category: category,
          sound: NotificationSound.defaultSound,
          priority: NotificationPriority.normal,
        );
    }
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'category': category.index,
      'sound': sound.index,
      'priority': priority.index,
      'vibrate': vibrate ? 1 : 0,
      'advanceMinutes': advanceMinutes,
      'enableLED': enableLED ? 1 : 0,
      'ledColor': ledColor?.value,
    };
  }

  /// Create from map
  factory NotificationConfig.fromMap(Map<String, dynamic> map) {
    return NotificationConfig(
      category: ReminderCategory.values[map['category'] as int],
      sound: NotificationSound.values[map['sound'] as int? ?? 0],
      priority: NotificationPriority.values[map['priority'] as int? ?? 1],
      vibrate: (map['vibrate'] as int?) == 1,
      advanceMinutes: map['advanceMinutes'] as int?,
      enableLED: (map['enableLED'] as int?) == 1,
      ledColor: map['ledColor'] != null ? Color(map['ledColor'] as int) : null,
    );
  }

  /// Create a copy with updated fields
  NotificationConfig copyWith({
    ReminderCategory? category,
    NotificationSound? sound,
    NotificationPriority? priority,
    bool? vibrate,
    int? advanceMinutes,
    bool? enableLED,
    Color? ledColor,
  }) {
    return NotificationConfig(
      category: category ?? this.category,
      sound: sound ?? this.sound,
      priority: priority ?? this.priority,
      vibrate: vibrate ?? this.vibrate,
      advanceMinutes: advanceMinutes ?? this.advanceMinutes,
      enableLED: enableLED ?? this.enableLED,
      ledColor: ledColor ?? this.ledColor,
    );
  }
}

/// Silent hours configuration
class SilentHours {
  final bool enabled;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> activeDays; // 1-7 for Mon-Sun
  final bool allowUrgent; // Allow urgent notifications even during silent hours

  const SilentHours({
    this.enabled = false,
    this.startTime = const TimeOfDay(hour: 22, minute: 0),
    this.endTime = const TimeOfDay(hour: 7, minute: 0),
    this.activeDays = const [1, 2, 3, 4, 5, 6, 7], // All days
    this.allowUrgent = true,
  });

  /// Check if current time is within silent hours
  bool isInSilentHours([DateTime? now]) {
    if (!enabled) return false;

    final currentTime = now ?? DateTime.now();
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    // Check if today is an active day
    if (!activeDays.contains(currentTime.weekday)) return false;

    // Handle overnight silent hours (e.g., 22:00 to 7:00)
    if (startMinutes > endMinutes) {
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    } else {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled ? 1 : 0,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'activeDays': activeDays.join(','),
      'allowUrgent': allowUrgent ? 1 : 0,
    };
  }

  /// Create from map
  factory SilentHours.fromMap(Map<String, dynamic> map) {
    return SilentHours(
      enabled: (map['enabled'] as int?) == 1,
      startTime: TimeOfDay(
        hour: map['startHour'] as int? ?? 22,
        minute: map['startMinute'] as int? ?? 0,
      ),
      endTime: TimeOfDay(
        hour: map['endHour'] as int? ?? 7,
        minute: map['endMinute'] as int? ?? 0,
      ),
      activeDays: map['activeDays'] != null
          ? (map['activeDays'] as String).split(',').map(int.parse).toList()
          : [1, 2, 3, 4, 5, 6, 7],
      allowUrgent: (map['allowUrgent'] as int?) == 1,
    );
  }

  /// Create a copy with updated fields
  SilentHours copyWith({
    bool? enabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<int>? activeDays,
    bool? allowUrgent,
  }) {
    return SilentHours(
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      activeDays: activeDays ?? this.activeDays,
      allowUrgent: allowUrgent ?? this.allowUrgent,
    );
  }
}
