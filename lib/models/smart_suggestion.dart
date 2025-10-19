/// Smart AI-powered suggestion model
class SmartSuggestion {
  final int? id;
  final SuggestionType type;
  final String title;
  final String description;
  final String reason; // Why this suggestion is being made
  final SuggestionPriority priority;
  final SuggestionSource source;
  final int? petId; // Specific pet or null for general
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isDismissed;
  final bool isAccepted;
  final Map<String, dynamic>? metadata; // Additional context data
  final String? actionType; // create_reminder, schedule_vet, etc.
  final Map<String, dynamic>? actionData; // Data for the action

  SmartSuggestion({
    this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.reason,
    this.priority = SuggestionPriority.medium,
    required this.source,
    this.petId,
    DateTime? createdAt,
    this.expiresAt,
    this.isDismissed = false,
    this.isAccepted = false,
    this.metadata,
    this.actionType,
    this.actionData,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if suggestion is still valid
  bool get isValid {
    if (isDismissed || isAccepted) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  /// Get priority icon
  String get priorityIcon {
    switch (priority) {
      case SuggestionPriority.low:
        return '💡';
      case SuggestionPriority.medium:
        return '⭐';
      case SuggestionPriority.high:
        return '🔔';
      case SuggestionPriority.urgent:
        return '⚠️';
    }
  }

  /// Get type icon
  String get typeIcon {
    switch (type) {
      case SuggestionType.feeding:
        return '🍖';
      case SuggestionType.seasonal:
        return '🌸';
      case SuggestionType.veterinary:
        return '🏥';
      case SuggestionType.weather:
        return '🌤️';
      case SuggestionType.milestone:
        return '🎂';
      case SuggestionType.exercise:
        return '🏃';
      case SuggestionType.grooming:
        return '✂️';
      case SuggestionType.training:
        return '🎓';
      case SuggestionType.social:
        return '🐕';
      case SuggestionType.general:
        return '📋';
    }
  }

  SmartSuggestion copyWith({
    int? id,
    SuggestionType? type,
    String? title,
    String? description,
    String? reason,
    SuggestionPriority? priority,
    SuggestionSource? source,
    int? petId,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isDismissed,
    bool? isAccepted,
    Map<String, dynamic>? metadata,
    String? actionType,
    Map<String, dynamic>? actionData,
  }) {
    return SmartSuggestion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      reason: reason ?? this.reason,
      priority: priority ?? this.priority,
      source: source ?? this.source,
      petId: petId ?? this.petId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isDismissed: isDismissed ?? this.isDismissed,
      isAccepted: isAccepted ?? this.isAccepted,
      metadata: metadata ?? this.metadata,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'description': description,
      'reason': reason,
      'priority': priority.index,
      'source': source.index,
      'petId': petId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isDismissed': isDismissed ? 1 : 0,
      'isAccepted': isAccepted ? 1 : 0,
      'metadata': metadata != null ? _encodeMetadata(metadata!) : null,
      'actionType': actionType,
      'actionData': actionData != null ? _encodeMetadata(actionData!) : null,
    };
  }

  factory SmartSuggestion.fromMap(Map<String, dynamic> map) {
    return SmartSuggestion(
      id: map['id'] as int?,
      type: SuggestionType.values[map['type'] as int],
      title: map['title'] as String,
      description: map['description'] as String,
      reason: map['reason'] as String,
      priority: SuggestionPriority.values[map['priority'] as int],
      source: SuggestionSource.values[map['source'] as int],
      petId: map['petId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt'] as String) : null,
      isDismissed: (map['isDismissed'] as int) == 1,
      isAccepted: (map['isAccepted'] as int) == 1,
      metadata: map['metadata'] != null ? _decodeMetadata(map['metadata'] as String) : null,
      actionType: map['actionType'] as String?,
      actionData: map['actionData'] != null ? _decodeMetadata(map['actionData'] as String) : null,
    );
  }

  static String _encodeMetadata(Map<String, dynamic> data) {
    // Simple JSON-like encoding
    return data.entries.map((e) => '${e.key}:${e.value}').join('|');
  }

  static Map<String, dynamic> _decodeMetadata(String encoded) {
    final Map<String, dynamic> result = {};
    for (final pair in encoded.split('|')) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        result[parts[0]] = parts[1];
      }
    }
    return result;
  }
}

/// Type of suggestion
enum SuggestionType {
  feeding,       // Optimal feeding times
  seasonal,      // Seasonal care (flea prevention, etc.)
  veterinary,    // Vet visit reminders
  weather,       // Weather-based activities
  milestone,     // Age-based milestones
  exercise,      // Exercise recommendations
  grooming,      // Grooming schedules
  training,      // Training activities
  social,        // Socialization opportunities
  general,       // General care tips
}

/// Priority level of suggestion
enum SuggestionPriority {
  low,
  medium,
  high,
  urgent,
}

/// Source of suggestion
enum SuggestionSource {
  aiAnalysis,       // AI-generated from pet data
  bestPractices,    // From pet care knowledge base
  seasonal,         // Season-based recommendations
  weather,          // Weather-triggered suggestions
  ageBasedMilestone, // Age-appropriate milestones
  veterinarySchedule, // Standard vet schedules
  userHistory,      // Based on user's past behavior
}

extension SuggestionTypeExtension on SuggestionType {
  String get displayName {
    switch (this) {
      case SuggestionType.feeding:
        return 'Feeding';
      case SuggestionType.seasonal:
        return 'Seasonal Care';
      case SuggestionType.veterinary:
        return 'Veterinary';
      case SuggestionType.weather:
        return 'Weather-Based';
      case SuggestionType.milestone:
        return 'Milestone';
      case SuggestionType.exercise:
        return 'Exercise';
      case SuggestionType.grooming:
        return 'Grooming';
      case SuggestionType.training:
        return 'Training';
      case SuggestionType.social:
        return 'Social';
      case SuggestionType.general:
        return 'General Care';
    }
  }
}
