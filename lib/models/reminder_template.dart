import 'reminder.dart';
import 'reminder_category.dart';
import 'notification_config.dart';

/// Reminder template for quick reminder creation
/// Can be customized per pet or shared globally
class ReminderTemplate {
  final int? id;
  final String name; // Template name (e.g., "Daily Feeding", "Weekly Grooming")
  final String title;
  final String description;
  final String time; // Default time in HH:mm format
  final ReminderCategory category;
  final RecurrencePattern recurrencePattern;
  final int? customIntervalValue;
  final IntervalUnit? customIntervalUnit;
  final List<int>? weekdays;
  final int? dayOfMonth;
  final bool autoAdjustForAge;
  final NotificationPriority notificationPriority;
  final NotificationSound notificationSound;
  final int? advanceReminderMinutes;
  final bool enableAdvanceReminder;
  final int? petId; // null for global templates, specific petId for per-pet templates
  final String? petGroup; // null for all pets, specific group for group templates
  final bool isGlobal; // true if template is available for all pets

  ReminderTemplate({
    this.id,
    required this.name,
    required this.title,
    this.description = '',
    required this.time,
    this.category = ReminderCategory.other,
    this.recurrencePattern = RecurrencePattern.daily,
    this.customIntervalValue,
    this.customIntervalUnit,
    this.weekdays,
    this.dayOfMonth,
    this.autoAdjustForAge = false,
    this.notificationPriority = NotificationPriority.normal,
    this.notificationSound = NotificationSound.defaultSound,
    this.advanceReminderMinutes,
    this.enableAdvanceReminder = false,
    this.petId,
    this.petGroup,
    this.isGlobal = true,
  });

  /// Convert template to a reminder for a specific pet
  Reminder toReminder({required int petId, int? reminderId}) {
    return Reminder(
      id: reminderId ?? DateTime.now().millisecondsSinceEpoch,
      title: title,
      description: description,
      time: time,
      isActive: true,
      petId: petId,
      category: category,
      recurrencePattern: recurrencePattern,
      customIntervalValue: customIntervalValue,
      customIntervalUnit: customIntervalUnit,
      weekdays: weekdays,
      dayOfMonth: dayOfMonth,
      autoAdjustForAge: autoAdjustForAge,
      notificationPriority: notificationPriority,
      notificationSound: notificationSound,
      advanceReminderMinutes: advanceReminderMinutes,
      enableAdvanceReminder: enableAdvanceReminder,
      startDate: DateTime.now(),
      nextScheduled: null, // Will be calculated
    );
  }

  /// Create a copy with modified fields
  ReminderTemplate copyWith({
    int? id,
    String? name,
    String? title,
    String? description,
    String? time,
    ReminderCategory? category,
    RecurrencePattern? recurrencePattern,
    int? customIntervalValue,
    IntervalUnit? customIntervalUnit,
    List<int>? weekdays,
    int? dayOfMonth,
    bool? autoAdjustForAge,
    NotificationPriority? notificationPriority,
    NotificationSound? notificationSound,
    int? advanceReminderMinutes,
    bool? enableAdvanceReminder,
    int? petId,
    String? petGroup,
    bool? isGlobal,
  }) {
    return ReminderTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      category: category ?? this.category,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      customIntervalValue: customIntervalValue ?? this.customIntervalValue,
      customIntervalUnit: customIntervalUnit ?? this.customIntervalUnit,
      weekdays: weekdays ?? this.weekdays,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      autoAdjustForAge: autoAdjustForAge ?? this.autoAdjustForAge,
      notificationPriority: notificationPriority ?? this.notificationPriority,
      notificationSound: notificationSound ?? this.notificationSound,
      advanceReminderMinutes: advanceReminderMinutes ?? this.advanceReminderMinutes,
      enableAdvanceReminder: enableAdvanceReminder ?? this.enableAdvanceReminder,
      petId: petId ?? this.petId,
      petGroup: petGroup ?? this.petGroup,
      isGlobal: isGlobal ?? this.isGlobal,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'time': time,
      'category': category.index,
      'recurrencePattern': recurrencePattern.index,
      'customIntervalValue': customIntervalValue,
      'customIntervalUnit': customIntervalUnit?.index,
      'weekdays': weekdays?.join(','),
      'dayOfMonth': dayOfMonth,
      'autoAdjustForAge': autoAdjustForAge ? 1 : 0,
      'notificationPriority': notificationPriority.index,
      'notificationSound': notificationSound.index,
      'advanceReminderMinutes': advanceReminderMinutes,
      'enableAdvanceReminder': enableAdvanceReminder ? 1 : 0,
      'petId': petId,
      'petGroup': petGroup,
      'isGlobal': isGlobal ? 1 : 0,
    };
  }

  /// Create from database map
  factory ReminderTemplate.fromMap(Map<String, dynamic> map) {
    return ReminderTemplate(
      id: map['id'] as int?,
      name: map['name'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      time: map['time'] as String,
      category: map['category'] != null
          ? ReminderCategory.values[map['category'] as int]
          : ReminderCategory.other,
      recurrencePattern: map['recurrencePattern'] != null
          ? RecurrencePattern.values[map['recurrencePattern'] as int]
          : RecurrencePattern.daily,
      customIntervalValue: map['customIntervalValue'] as int?,
      customIntervalUnit: map['customIntervalUnit'] != null
          ? IntervalUnit.values[map['customIntervalUnit'] as int]
          : null,
      weekdays: map['weekdays'] != null && (map['weekdays'] as String).isNotEmpty
          ? (map['weekdays'] as String).split(',').map((e) => int.parse(e)).toList()
          : null,
      dayOfMonth: map['dayOfMonth'] as int?,
      autoAdjustForAge: (map['autoAdjustForAge'] as int?) == 1,
      notificationPriority: map['notificationPriority'] != null
          ? NotificationPriority.values[map['notificationPriority'] as int]
          : NotificationPriority.normal,
      notificationSound: map['notificationSound'] != null
          ? NotificationSound.values[map['notificationSound'] as int]
          : NotificationSound.defaultSound,
      advanceReminderMinutes: map['advanceReminderMinutes'] as int?,
      enableAdvanceReminder: (map['enableAdvanceReminder'] as int?) == 1,
      petId: map['petId'] as int?,
      petGroup: map['petGroup'] as String?,
      isGlobal: (map['isGlobal'] as int?) == 1,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// Create from JSON
  factory ReminderTemplate.fromJson(Map<String, dynamic> json) =>
      ReminderTemplate.fromMap(json);

  /// Get a display description of the template
  String get displayDescription {
    final recurrence = recurrencePattern == RecurrencePattern.none
        ? 'One-time'
        : recurrencePattern == RecurrencePattern.daily
            ? 'Daily'
            : recurrencePattern == RecurrencePattern.weekly
                ? 'Weekly'
                : recurrencePattern == RecurrencePattern.monthly
                    ? 'Monthly'
                    : 'Custom';
    
    final scope = isGlobal
        ? 'Global'
        : petId != null
            ? 'Pet-specific'
            : petGroup != null
                ? 'Group: $petGroup'
                : 'Custom';
    
    return '$recurrence • $scope • ${category.displayName}';
  }

  /// Pre-defined templates for common pet care tasks
  static List<ReminderTemplate> getDefaultTemplates() {
    return [
      ReminderTemplate(
        name: 'Morning Feeding',
        title: 'Morning Feeding',
        description: 'Feed your pet breakfast',
        time: '08:00',
        category: ReminderCategory.feeding,
        recurrencePattern: RecurrencePattern.daily,
        notificationPriority: NotificationPriority.high,
      ),
      ReminderTemplate(
        name: 'Evening Feeding',
        title: 'Evening Feeding',
        description: 'Feed your pet dinner',
        time: '18:00',
        category: ReminderCategory.feeding,
        recurrencePattern: RecurrencePattern.daily,
        notificationPriority: NotificationPriority.high,
      ),
      ReminderTemplate(
        name: 'Daily Walk',
        title: 'Daily Walk',
        description: 'Take your pet for a walk',
        time: '17:00',
        category: ReminderCategory.walking,
        recurrencePattern: RecurrencePattern.daily,
      ),
      ReminderTemplate(
        name: 'Weekly Grooming',
        title: 'Weekly Grooming',
        description: 'Grooming session',
        time: '10:00',
        category: ReminderCategory.grooming,
        recurrencePattern: RecurrencePattern.weekly,
        weekdays: [6], // Saturday
      ),
      ReminderTemplate(
        name: 'Monthly Medication',
        title: 'Monthly Medication',
        description: 'Give monthly medication',
        time: '09:00',
        category: ReminderCategory.medication,
        recurrencePattern: RecurrencePattern.monthly,
        dayOfMonth: 1,
        notificationPriority: NotificationPriority.urgent,
      ),
    ];
  }
}
