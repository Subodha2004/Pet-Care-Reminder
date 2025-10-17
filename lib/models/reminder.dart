/// Recurrence pattern for reminders
enum RecurrencePattern {
  none,
  daily,
  weekly,
  monthly,
  custom,
}

/// Custom interval unit for recurring reminders
enum IntervalUnit {
  days,
  weeks,
  months,
}

/// Advanced reminder model with recurring support
class Reminder {
  final int id;
  final String title;
  final String description;
  final String time; // HH:mm format
  final bool isActive;
  final int? petId; // Optional link to a specific pet
  
  // Recurring features
  final RecurrencePattern recurrencePattern;
  final int? customIntervalValue; // e.g., "3" for every 3 days
  final IntervalUnit? customIntervalUnit; // e.g., "days" for every 3 days
  final List<int>? weekdays; // 1=Monday, 7=Sunday (for weekly pattern)
  final int? dayOfMonth; // 1-31 (for monthly pattern)
  
  // Smart scheduling
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? lastTriggered;
  final DateTime? nextScheduled;
  
  // Snooze functionality
  final DateTime? snoozedUntil;
  final int snoozeCount;
  
  // Pet age-based adjustments
  final bool autoAdjustForAge;
  final String? ageAdjustmentRule; // JSON string with age-based rules

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isActive = true,
    this.petId,
    this.recurrencePattern = RecurrencePattern.none,
    this.customIntervalValue,
    this.customIntervalUnit,
    this.weekdays,
    this.dayOfMonth,
    this.startDate,
    this.endDate,
    this.lastTriggered,
    this.nextScheduled,
    this.snoozedUntil,
    this.snoozeCount = 0,
    this.autoAdjustForAge = false,
    this.ageAdjustmentRule,
  });

  /// Check if reminder is currently snoozed
  bool get isSnoozed {
    if (snoozedUntil == null) return false;
    return DateTime.now().isBefore(snoozedUntil!);
  }

  /// Get human-readable recurrence description
  String get recurrenceDescription {
    switch (recurrencePattern) {
      case RecurrencePattern.none:
        return 'One-time';
      case RecurrencePattern.daily:
        return 'Every day';
      case RecurrencePattern.weekly:
        if (weekdays == null || weekdays!.isEmpty) {
          return 'Weekly';
        }
        final days = _weekdayNames(weekdays!);
        return 'Every ${days.join(', ')}';
      case RecurrencePattern.monthly:
        if (dayOfMonth != null) {
          return 'Monthly on day $dayOfMonth';
        }
        return 'Monthly';
      case RecurrencePattern.custom:
        if (customIntervalValue != null && customIntervalUnit != null) {
          final unit = customIntervalUnit == IntervalUnit.days
              ? 'day'
              : customIntervalUnit == IntervalUnit.weeks
                  ? 'week'
                  : 'month';
          final plural = customIntervalValue! > 1 ? '${unit}s' : unit;
          return 'Every $customIntervalValue $plural';
        }
        return 'Custom';
    }
  }

  /// Convert weekday numbers to names
  List<String> _weekdayNames(List<int> days) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => names[d - 1]).toList();
  }

  /// Calculate next occurrence based on recurrence pattern
  DateTime? calculateNextOccurrence({DateTime? from}) {
    final baseDate = from ?? DateTime.now();
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    DateTime nextDate = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );

    // If the time has already passed today, start from tomorrow
    if (nextDate.isBefore(baseDate)) {
      nextDate = nextDate.add(const Duration(days: 1));
    }

    switch (recurrencePattern) {
      case RecurrencePattern.none:
        return nextDate;

      case RecurrencePattern.daily:
        return nextDate;

      case RecurrencePattern.weekly:
        if (weekdays == null || weekdays!.isEmpty) {
          return nextDate.add(const Duration(days: 7));
        }
        // Find next matching weekday
        for (int i = 0; i < 7; i++) {
          final checkDate = nextDate.add(Duration(days: i));
          if (weekdays!.contains(checkDate.weekday)) {
            return checkDate;
          }
        }
        return nextDate.add(const Duration(days: 7));

      case RecurrencePattern.monthly:
        int targetDay = dayOfMonth ?? baseDate.day;
        DateTime monthDate = DateTime(nextDate.year, nextDate.month, targetDay, hour, minute);
        
        if (monthDate.isBefore(baseDate)) {
          // Move to next month
          monthDate = DateTime(nextDate.year, nextDate.month + 1, targetDay, hour, minute);
        }
        
        // Handle invalid dates (e.g., Feb 30)
        while (monthDate.month != (nextDate.month % 12) + 1) {
          targetDay--;
          monthDate = DateTime(nextDate.year, nextDate.month + 1, targetDay, hour, minute);
        }
        return monthDate;

      case RecurrencePattern.custom:
        if (customIntervalValue == null || customIntervalUnit == null) {
          return nextDate;
        }
        
        switch (customIntervalUnit!) {
          case IntervalUnit.days:
            return nextDate.add(Duration(days: customIntervalValue!));
          case IntervalUnit.weeks:
            return nextDate.add(Duration(days: customIntervalValue! * 7));
          case IntervalUnit.months:
            return DateTime(
              nextDate.year,
              nextDate.month + customIntervalValue!,
              nextDate.day,
              hour,
              minute,
            );
        }
    }
  }

  /// Create a copy with updated fields
  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    String? time,
    bool? isActive,
    int? petId,
    RecurrencePattern? recurrencePattern,
    int? customIntervalValue,
    IntervalUnit? customIntervalUnit,
    List<int>? weekdays,
    int? dayOfMonth,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastTriggered,
    DateTime? nextScheduled,
    DateTime? snoozedUntil,
    int? snoozeCount,
    bool? autoAdjustForAge,
    String? ageAdjustmentRule,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      petId: petId ?? this.petId,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      customIntervalValue: customIntervalValue ?? this.customIntervalValue,
      customIntervalUnit: customIntervalUnit ?? this.customIntervalUnit,
      weekdays: weekdays ?? this.weekdays,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      nextScheduled: nextScheduled ?? this.nextScheduled,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      autoAdjustForAge: autoAdjustForAge ?? this.autoAdjustForAge,
      ageAdjustmentRule: ageAdjustmentRule ?? this.ageAdjustmentRule,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'isActive': isActive ? 1 : 0,
      'petId': petId,
      'recurrencePattern': recurrencePattern.index,
      'customIntervalValue': customIntervalValue,
      'customIntervalUnit': customIntervalUnit?.index,
      'weekdays': weekdays?.join(','),
      'dayOfMonth': dayOfMonth,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
      'nextScheduled': nextScheduled?.toIso8601String(),
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'snoozeCount': snoozeCount,
      'autoAdjustForAge': autoAdjustForAge ? 1 : 0,
      'ageAdjustmentRule': ageAdjustmentRule,
    };
  }

  /// Create from database map
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      time: map['time'] as String,
      isActive: (map['isActive'] as int) == 1,
      petId: map['petId'] as int?,
      recurrencePattern: RecurrencePattern.values[map['recurrencePattern'] as int? ?? 0],
      customIntervalValue: map['customIntervalValue'] as int?,
      customIntervalUnit: map['customIntervalUnit'] != null
          ? IntervalUnit.values[map['customIntervalUnit'] as int]
          : null,
      weekdays: map['weekdays'] != null
          ? (map['weekdays'] as String).split(',').map((e) => int.parse(e)).toList()
          : null,
      dayOfMonth: map['dayOfMonth'] as int?,
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate'] as String) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      lastTriggered: map['lastTriggered'] != null ? DateTime.parse(map['lastTriggered'] as String) : null,
      nextScheduled: map['nextScheduled'] != null ? DateTime.parse(map['nextScheduled'] as String) : null,
      snoozedUntil: map['snoozedUntil'] != null ? DateTime.parse(map['snoozedUntil'] as String) : null,
      snoozeCount: map['snoozeCount'] as int? ?? 0,
      autoAdjustForAge: (map['autoAdjustForAge'] as int?) == 1,
      ageAdjustmentRule: map['ageAdjustmentRule'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// Create from JSON
  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder.fromMap(json);
}
