import 'reminder_category.dart';

/// Actions that can be taken on a notification
enum NotificationAction {
  viewed,
  dismissed,
  snoozed,
  markedAsDone,
  rescheduled,
}

/// Extension for NotificationAction
extension NotificationActionExtension on NotificationAction {
  /// Display name for action
  String get displayName {
    switch (this) {
      case NotificationAction.viewed:
        return 'Viewed';
      case NotificationAction.dismissed:
        return 'Dismissed';
      case NotificationAction.snoozed:
        return 'Snoozed';
      case NotificationAction.markedAsDone:
        return 'Completed';
      case NotificationAction.rescheduled:
        return 'Rescheduled';
    }
  }
}

/// History entry for a notification
class NotificationHistory {
  final int id;
  final int reminderId;
  final String title;
  final String body;
  final ReminderCategory category;
  final DateTime scheduledTime;
  final DateTime? deliveredTime;
  final DateTime? actionTime;
  final NotificationAction? action;
  final String? actionDetails; // JSON with additional info (e.g., snooze duration)
  final bool wasDelivered;
  final bool wasSilenced; // Silenced due to silent hours

  const NotificationHistory({
    required this.id,
    required this.reminderId,
    required this.title,
    required this.body,
    required this.category,
    required this.scheduledTime,
    this.deliveredTime,
    this.actionTime,
    this.action,
    this.actionDetails,
    this.wasDelivered = false,
    this.wasSilenced = false,
  });

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderId': reminderId,
      'title': title,
      'body': body,
      'category': category.index,
      'scheduledTime': scheduledTime.toIso8601String(),
      'deliveredTime': deliveredTime?.toIso8601String(),
      'actionTime': actionTime?.toIso8601String(),
      'action': action?.index,
      'actionDetails': actionDetails,
      'wasDelivered': wasDelivered ? 1 : 0,
      'wasSilenced': wasSilenced ? 1 : 0,
    };
  }

  /// Create from database map
  factory NotificationHistory.fromMap(Map<String, dynamic> map) {
    return NotificationHistory(
      id: map['id'] as int,
      reminderId: map['reminderId'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      category: ReminderCategory.values[map['category'] as int],
      scheduledTime: DateTime.parse(map['scheduledTime'] as String),
      deliveredTime: map['deliveredTime'] != null
          ? DateTime.parse(map['deliveredTime'] as String)
          : null,
      actionTime: map['actionTime'] != null
          ? DateTime.parse(map['actionTime'] as String)
          : null,
      action: map['action'] != null
          ? NotificationAction.values[map['action'] as int]
          : null,
      actionDetails: map['actionDetails'] as String?,
      wasDelivered: (map['wasDelivered'] as int?) == 1,
      wasSilenced: (map['wasSilenced'] as int?) == 1,
    );
  }

  /// Create a copy with updated fields
  NotificationHistory copyWith({
    int? id,
    int? reminderId,
    String? title,
    String? body,
    ReminderCategory? category,
    DateTime? scheduledTime,
    DateTime? deliveredTime,
    DateTime? actionTime,
    NotificationAction? action,
    String? actionDetails,
    bool? wasDelivered,
    bool? wasSilenced,
  }) {
    return NotificationHistory(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      deliveredTime: deliveredTime ?? this.deliveredTime,
      actionTime: actionTime ?? this.actionTime,
      action: action ?? this.action,
      actionDetails: actionDetails ?? this.actionDetails,
      wasDelivered: wasDelivered ?? this.wasDelivered,
      wasSilenced: wasSilenced ?? this.wasSilenced,
    );
  }

  /// Get formatted time difference
  String getTimeDifference() {
    final now = DateTime.now();
    final time = deliveredTime ?? scheduledTime;
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }
}
