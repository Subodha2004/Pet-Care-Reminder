import 'package:flutter/material.dart';

/// Pre-defined reminder categories for pet care
enum ReminderCategory {
  feeding,
  walking,
  medication,
  grooming,
  vetVisit,
  playTime,
  training,
  other,
}

/// Extension to add category metadata
extension ReminderCategoryExtension on ReminderCategory {
  /// Display name for the category
  String get displayName {
    switch (this) {
      case ReminderCategory.feeding:
        return 'Feeding';
      case ReminderCategory.walking:
        return 'Walking';
      case ReminderCategory.medication:
        return 'Medication';
      case ReminderCategory.grooming:
        return 'Grooming';
      case ReminderCategory.vetVisit:
        return 'Vet Visit';
      case ReminderCategory.playTime:
        return 'Play Time';
      case ReminderCategory.training:
        return 'Training';
      case ReminderCategory.other:
        return 'Other';
    }
  }

  /// Icon for the category
  IconData get icon {
    switch (this) {
      case ReminderCategory.feeding:
        return Icons.restaurant_rounded;
      case ReminderCategory.walking:
        return Icons.directions_walk_rounded;
      case ReminderCategory.medication:
        return Icons.medication_rounded;
      case ReminderCategory.grooming:
        return Icons.shower_rounded;
      case ReminderCategory.vetVisit:
        return Icons.medical_services_rounded;
      case ReminderCategory.playTime:
        return Icons.sports_esports_rounded;
      case ReminderCategory.training:
        return Icons.school_rounded;
      case ReminderCategory.other:
        return Icons.pets_rounded;
    }
  }

  /// Color for the category
  Color get color {
    switch (this) {
      case ReminderCategory.feeding:
        return const Color(0xFFFF9800); // Orange
      case ReminderCategory.walking:
        return const Color(0xFF4CAF50); // Green
      case ReminderCategory.medication:
        return const Color(0xFFF44336); // Red
      case ReminderCategory.grooming:
        return const Color(0xFF2196F3); // Blue
      case ReminderCategory.vetVisit:
        return const Color(0xFF9C27B0); // Purple
      case ReminderCategory.playTime:
        return const Color(0xFFFFEB3B); // Yellow
      case ReminderCategory.training:
        return const Color(0xFF00BCD4); // Cyan
      case ReminderCategory.other:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }

  /// Gradient colors for the category card
  List<Color> get gradientColors {
    final baseColor = color;
    return [
      baseColor.withOpacity(0.3),
      baseColor.withOpacity(0.15),
    ];
  }

  /// Description/example for the category
  String get description {
    switch (this) {
      case ReminderCategory.feeding:
        return 'Meal times, treats, supplements';
      case ReminderCategory.walking:
        return 'Daily walks, exercise, outdoor time';
      case ReminderCategory.medication:
        return 'Pills, treatments, vaccines';
      case ReminderCategory.grooming:
        return 'Bathing, brushing, nail trimming';
      case ReminderCategory.vetVisit:
        return 'Check-ups, appointments, emergencies';
      case ReminderCategory.playTime:
        return 'Interactive play, toys, games';
      case ReminderCategory.training:
        return 'Obedience, tricks, socialization';
      case ReminderCategory.other:
        return 'Custom reminders';
    }
  }

  /// Quick templates for the category
  List<QuickTemplate> get quickTemplates {
    switch (this) {
      case ReminderCategory.feeding:
        return [
          QuickTemplate(
            title: 'Morning Feeding',
            description: 'Regular morning meal',
            defaultTime: '08:00',
            recurrencePattern: 0, // Daily
          ),
          QuickTemplate(
            title: 'Evening Feeding',
            description: 'Regular evening meal',
            defaultTime: '18:00',
            recurrencePattern: 0,
          ),
          QuickTemplate(
            title: 'Lunch Feeding',
            description: 'Midday meal',
            defaultTime: '12:00',
            recurrencePattern: 0,
          ),
        ];
      case ReminderCategory.walking:
        return [
          QuickTemplate(
            title: 'Morning Walk',
            description: 'Start the day with exercise',
            defaultTime: '07:00',
            recurrencePattern: 0,
          ),
          QuickTemplate(
            title: 'Evening Walk',
            description: 'Evening exercise routine',
            defaultTime: '17:00',
            recurrencePattern: 0,
          ),
          QuickTemplate(
            title: 'Weekend Long Walk',
            description: 'Extended weekend walk',
            defaultTime: '09:00',
            recurrencePattern: 1, // Weekly
            weekdays: [6, 7], // Sat, Sun
          ),
        ];
      case ReminderCategory.medication:
        return [
          QuickTemplate(
            title: 'Daily Medication',
            description: 'Regular medication dose',
            defaultTime: '09:00',
            recurrencePattern: 0,
          ),
          QuickTemplate(
            title: 'Flea & Tick Treatment',
            description: 'Monthly prevention treatment',
            defaultTime: '10:00',
            recurrencePattern: 2, // Monthly
            dayOfMonth: 1,
          ),
          QuickTemplate(
            title: 'Heartworm Prevention',
            description: 'Monthly heartworm medication',
            defaultTime: '10:00',
            recurrencePattern: 2,
            dayOfMonth: 1,
          ),
        ];
      case ReminderCategory.grooming:
        return [
          QuickTemplate(
            title: 'Brush Fur',
            description: 'Daily brushing session',
            defaultTime: '19:00',
            recurrencePattern: 0,
          ),
          QuickTemplate(
            title: 'Bath Time',
            description: 'Weekly bath',
            defaultTime: '14:00',
            recurrencePattern: 1,
            weekdays: [7], // Sunday
          ),
          QuickTemplate(
            title: 'Nail Trimming',
            description: 'Trim nails every 2 weeks',
            defaultTime: '15:00',
            recurrencePattern: 3, // Custom
            customIntervalValue: 2,
            customIntervalUnit: 1, // Weeks
          ),
        ];
      case ReminderCategory.vetVisit:
        return [
          QuickTemplate(
            title: 'Annual Check-up',
            description: 'Yearly health examination',
            defaultTime: '10:00',
            recurrencePattern: 3,
            customIntervalValue: 12,
            customIntervalUnit: 2, // Months
          ),
          QuickTemplate(
            title: 'Vaccination',
            description: 'Scheduled vaccine appointment',
            defaultTime: '11:00',
            recurrencePattern: 3,
            customIntervalValue: 6,
            customIntervalUnit: 2,
          ),
          QuickTemplate(
            title: 'Dental Check-up',
            description: 'Dental health examination',
            defaultTime: '14:00',
            recurrencePattern: 3,
            customIntervalValue: 6,
            customIntervalUnit: 2,
          ),
        ];
      case ReminderCategory.playTime:
        return [
          QuickTemplate(
            title: 'Interactive Play',
            description: 'Quality playtime',
            defaultTime: '16:00',
            recurrencePattern: 0,
          ),
          QuickTemplate(
            title: 'Training Games',
            description: 'Mental stimulation activities',
            defaultTime: '11:00',
            recurrencePattern: 1,
            weekdays: [1, 3, 5], // Mon, Wed, Fri
          ),
        ];
      case ReminderCategory.training:
        return [
          QuickTemplate(
            title: 'Training Session',
            description: 'Regular training practice',
            defaultTime: '10:00',
            recurrencePattern: 1,
            weekdays: [1, 3, 5],
          ),
          QuickTemplate(
            title: 'Socialization',
            description: 'Meet other pets',
            defaultTime: '16:00',
            recurrencePattern: 1,
            weekdays: [6], // Saturday
          ),
        ];
      case ReminderCategory.other:
        return [
          QuickTemplate(
            title: 'Custom Reminder',
            description: 'Set your own reminder',
            defaultTime: '12:00',
            recurrencePattern: 0,
          ),
        ];
    }
  }

  /// Auto-detect category from title text
  static ReminderCategory detectFromTitle(String title) {
    final titleLower = title.toLowerCase();
    
    if (titleLower.contains('feed') || 
        titleLower.contains('food') || 
        titleLower.contains('meal') ||
        titleLower.contains('breakfast') ||
        titleLower.contains('lunch') ||
        titleLower.contains('dinner')) {
      return ReminderCategory.feeding;
    }
    
    if (titleLower.contains('walk') || 
        titleLower.contains('exercise') ||
        titleLower.contains('run') ||
        titleLower.contains('jog')) {
      return ReminderCategory.walking;
    }
    
    if (titleLower.contains('medicine') || 
        titleLower.contains('pill') ||
        titleLower.contains('medication') ||
        titleLower.contains('dose') ||
        titleLower.contains('treatment') ||
        titleLower.contains('vaccine')) {
      return ReminderCategory.medication;
    }
    
    if (titleLower.contains('groom') || 
        titleLower.contains('bath') ||
        titleLower.contains('brush') ||
        titleLower.contains('trim') ||
        titleLower.contains('nail')) {
      return ReminderCategory.grooming;
    }
    
    if (titleLower.contains('vet') || 
        titleLower.contains('doctor') ||
        titleLower.contains('medical') ||
        titleLower.contains('clinic') ||
        titleLower.contains('checkup') ||
        titleLower.contains('check-up')) {
      return ReminderCategory.vetVisit;
    }
    
    if (titleLower.contains('play') || 
        titleLower.contains('game') ||
        titleLower.contains('toy')) {
      return ReminderCategory.playTime;
    }
    
    if (titleLower.contains('train') || 
        titleLower.contains('practice') ||
        titleLower.contains('learn') ||
        titleLower.contains('trick')) {
      return ReminderCategory.training;
    }
    
    return ReminderCategory.other;
  }
}

/// Quick template for creating reminders
class QuickTemplate {
  final String title;
  final String description;
  final String defaultTime;
  final int recurrencePattern; // Index of RecurrencePattern enum
  final List<int>? weekdays;
  final int? dayOfMonth;
  final int? customIntervalValue;
  final int? customIntervalUnit; // Index of IntervalUnit enum

  const QuickTemplate({
    required this.title,
    required this.description,
    required this.defaultTime,
    required this.recurrencePattern,
    this.weekdays,
    this.dayOfMonth,
    this.customIntervalValue,
    this.customIntervalUnit,
  });
}
