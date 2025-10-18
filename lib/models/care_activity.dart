import 'reminder_category.dart';

/// Represents a completed care activity
class CareActivity {
  final int id;
  final int reminderId;
  final int? petId;
  final String title;
  final String description;
  final ReminderCategory category;
  final DateTime completedAt;
  final DateTime scheduledTime;
  final String? notes; // User notes about the activity
  final int? durationMinutes; // For activities like walks
  final Map<String, dynamic>? metadata; // Additional data (e.g., food amount, walk distance)
  final String? photoPath; // Optional photo of the activity
  final bool wasOnTime; // Completed within acceptable window

  CareActivity({
    required this.id,
    required this.reminderId,
    this.petId,
    required this.title,
    required this.description,
    required this.category,
    required this.completedAt,
    required this.scheduledTime,
    this.notes,
    this.durationMinutes,
    this.metadata,
    this.photoPath,
    bool? wasOnTime,
  }) : wasOnTime = wasOnTime ?? _calculateWasOnTime(completedAt, scheduledTime);

  /// Calculate if activity was completed on time (within 30 minutes)
  static bool _calculateWasOnTime(DateTime completedAt, DateTime scheduledTime) {
    final difference = completedAt.difference(scheduledTime).abs();
    return difference.inMinutes <= 30;
  }

  /// Get time difference from scheduled time
  Duration getTimeDifference() {
    return completedAt.difference(scheduledTime);
  }

  /// Get formatted time difference
  String getFormattedTimeDifference() {
    final diff = getTimeDifference();
    final isLate = diff.isNegative ? false : true;
    final absDiff = diff.abs();

    if (absDiff.inMinutes < 1) {
      return 'On time';
    } else if (absDiff.inMinutes <= 30) {
      return '${absDiff.inMinutes}min ${isLate ? "late" : "early"}';
    } else if (absDiff.inHours < 24) {
      return '${absDiff.inHours}h ${isLate ? "late" : "early"}';
    } else {
      return '${absDiff.inDays}d ${isLate ? "late" : "early"}';
    }
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderId': reminderId,
      'petId': petId,
      'title': title,
      'description': description,
      'category': category.index,
      'completedAt': completedAt.toIso8601String(),
      'scheduledTime': scheduledTime.toIso8601String(),
      'notes': notes,
      'durationMinutes': durationMinutes,
      'metadata': metadata != null ? _encodeMetadata(metadata!) : null,
      'photoPath': photoPath,
      'wasOnTime': wasOnTime ? 1 : 0,
    };
  }

  /// Create from database map
  factory CareActivity.fromMap(Map<String, dynamic> map) {
    return CareActivity(
      id: map['id'] as int,
      reminderId: map['reminderId'] as int,
      petId: map['petId'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      category: ReminderCategory.values[map['category'] as int],
      completedAt: DateTime.parse(map['completedAt'] as String),
      scheduledTime: DateTime.parse(map['scheduledTime'] as String),
      notes: map['notes'] as String?,
      durationMinutes: map['durationMinutes'] as int?,
      metadata: map['metadata'] != null ? _decodeMetadata(map['metadata'] as String) : null,
      photoPath: map['photoPath'] as String?,
      wasOnTime: (map['wasOnTime'] as int?) == 1,
    );
  }

  /// Encode metadata to JSON string
  static String _encodeMetadata(Map<String, dynamic> metadata) {
    // Simple key-value encoding
    return metadata.entries.map((e) => '${e.key}:${e.value}').join(',');
  }

  /// Decode metadata from JSON string
  static Map<String, dynamic> _decodeMetadata(String encoded) {
    final map = <String, dynamic>{};
    if (encoded.isEmpty) return map;
    
    for (final pair in encoded.split(',')) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }

  /// Create a copy with updated fields
  CareActivity copyWith({
    int? id,
    int? reminderId,
    int? petId,
    String? title,
    String? description,
    ReminderCategory? category,
    DateTime? completedAt,
    DateTime? scheduledTime,
    String? notes,
    int? durationMinutes,
    Map<String, dynamic>? metadata,
    String? photoPath,
    bool? wasOnTime,
  }) {
    return CareActivity(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      completedAt: completedAt ?? this.completedAt,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      notes: notes ?? this.notes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      metadata: metadata ?? this.metadata,
      photoPath: photoPath ?? this.photoPath,
      wasOnTime: wasOnTime ?? this.wasOnTime,
    );
  }
}

/// Statistics for a specific category or overall
class ActivityStatistics {
  final ReminderCategory? category; // null for overall stats
  final int totalActivities;
  final int onTimeCount;
  final int lateCount;
  final double averageDurationMinutes;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final Map<String, int> activityCountByDay; // Day of week -> count
  final List<int> activityCountByHour; // Hour -> count (24 entries)

  ActivityStatistics({
    this.category,
    required this.totalActivities,
    required this.onTimeCount,
    required this.lateCount,
    required this.averageDurationMinutes,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    Map<String, int>? activityCountByDay,
    List<int>? activityCountByHour,
  })  : activityCountByDay = activityCountByDay ?? {},
        activityCountByHour = activityCountByHour ?? List.filled(24, 0);

  /// Calculate on-time percentage
  double get onTimePercentage {
    if (totalActivities == 0) return 0.0;
    return (onTimeCount / totalActivities) * 100;
  }

  /// Get most active day
  String? get mostActiveDay {
    if (activityCountByDay.isEmpty) return null;
    
    final sorted = activityCountByDay.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }

  /// Get most active hour
  int? get mostActiveHour {
    if (activityCountByHour.every((count) => count == 0)) return null;
    
    int maxCount = 0;
    int maxHour = 0;
    
    for (int i = 0; i < activityCountByHour.length; i++) {
      if (activityCountByHour[i] > maxCount) {
        maxCount = activityCountByHour[i];
        maxHour = i;
      }
    }
    
    return maxHour;
  }
}

/// Achievement/Badge for care activities
enum AchievementType {
  firstActivity,
  streak7Days,
  streak30Days,
  streak100Days,
  perfectWeek,
  perfectMonth,
  earlyBird, // Most activities before 9 AM
  nightOwl, // Most activities after 9 PM
  dedicated, // 100 total activities
  expert, // 500 total activities
  master, // 1000 total activities
}

/// Extension for achievement metadata
extension AchievementTypeExtension on AchievementType {
  String get displayName {
    switch (this) {
      case AchievementType.firstActivity:
        return 'First Steps';
      case AchievementType.streak7Days:
        return '7 Day Streak';
      case AchievementType.streak30Days:
        return '30 Day Streak';
      case AchievementType.streak100Days:
        return '100 Day Streak';
      case AchievementType.perfectWeek:
        return 'Perfect Week';
      case AchievementType.perfectMonth:
        return 'Perfect Month';
      case AchievementType.earlyBird:
        return 'Early Bird';
      case AchievementType.nightOwl:
        return 'Night Owl';
      case AchievementType.dedicated:
        return 'Dedicated Caregiver';
      case AchievementType.expert:
        return 'Expert Caregiver';
      case AchievementType.master:
        return 'Master Caregiver';
    }
  }

  String get description {
    switch (this) {
      case AchievementType.firstActivity:
        return 'Complete your first activity';
      case AchievementType.streak7Days:
        return 'Complete activities for 7 days in a row';
      case AchievementType.streak30Days:
        return 'Complete activities for 30 days in a row';
      case AchievementType.streak100Days:
        return 'Complete activities for 100 days in a row';
      case AchievementType.perfectWeek:
        return 'Complete all scheduled activities in a week';
      case AchievementType.perfectMonth:
        return 'Complete all scheduled activities in a month';
      case AchievementType.earlyBird:
        return 'Complete 50 activities before 9 AM';
      case AchievementType.nightOwl:
        return 'Complete 50 activities after 9 PM';
      case AchievementType.dedicated:
        return 'Complete 100 total activities';
      case AchievementType.expert:
        return 'Complete 500 total activities';
      case AchievementType.master:
        return 'Complete 1000 total activities';
    }
  }

  String get emoji {
    switch (this) {
      case AchievementType.firstActivity:
        return '🎯';
      case AchievementType.streak7Days:
        return '🔥';
      case AchievementType.streak30Days:
        return '⭐';
      case AchievementType.streak100Days:
        return '💎';
      case AchievementType.perfectWeek:
        return '✨';
      case AchievementType.perfectMonth:
        return '🏆';
      case AchievementType.earlyBird:
        return '🌅';
      case AchievementType.nightOwl:
        return '🌙';
      case AchievementType.dedicated:
        return '💪';
      case AchievementType.expert:
        return '🎓';
      case AchievementType.master:
        return '👑';
    }
  }
}

/// User achievement record
class Achievement {
  final int id;
  final AchievementType type;
  final DateTime earnedAt;
  final bool isNew; // For showing badge notification

  Achievement({
    required this.id,
    required this.type,
    required this.earnedAt,
    this.isNew = false,
  });

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'earnedAt': earnedAt.toIso8601String(),
      'isNew': isNew ? 1 : 0,
    };
  }

  /// Create from database map
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int,
      type: AchievementType.values[map['type'] as int],
      earnedAt: DateTime.parse(map['earnedAt'] as String),
      isNew: (map['isNew'] as int?) == 1,
    );
  }
}
