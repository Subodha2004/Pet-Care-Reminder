import 'dart:math';

/// Service for generating motivational messages and gamification content
class MotivationService {
  static final Random _random = Random();

  /// Get motivational message based on streak
  static String getStreakMessage(int streak) {
    if (streak == 0) {
      return _getMessages(_startMessages);
    } else if (streak < 7) {
      return _getMessages(_buildingMessages);
    } else if (streak < 30) {
      return _getMessages(_goodMessages);
    } else if (streak < 100) {
      return _getMessages(_greatMessages);
    } else {
      return _getMessages(_masterMessages);
    }
  }

  /// Get message for completing activity
  static String getCompletionMessage(bool wasOnTime) {
    if (wasOnTime) {
      return _getMessages(_onTimeMessages);
    } else {
      return _getMessages(_lateMessages);
    }
  }

  /// Get achievement unlock message
  static String getAchievementMessage(String achievementName) {
    final messages = [
      '🎉 Amazing! You unlocked "$achievementName"!',
      '⭐ Congratulations! "$achievementName" earned!',
      '🏆 Fantastic! You achieved "$achievementName"!',
      '✨ Incredible! "$achievementName" unlocked!',
      '💫 Awesome! You earned "$achievementName"!',
    ];
    return messages[_random.nextInt(messages.length)];
  }

  /// Get daily goal message
  static String getDailyGoalMessage(int completed, int total) {
    final percentage = (completed / total * 100).round();
    
    if (completed == 0) {
      return 'Start your day with one small task! 🌱';
    } else if (completed == total) {
      return 'Perfect! All tasks complete! 🎯';
    } else if (percentage >= 75) {
      return 'Almost there! Just ${ total - completed} more! 💪';
    } else if (percentage >= 50) {
      return 'Great progress! Keep going! 🌟';
    } else {
      return 'You\'re on your way! $completed done! 🚀';
    }
  }

  /// Get pet happiness message
  static String getPetHappinessMessage(double happiness) {
    if (happiness >= 90) {
      return 'Your pet is thriving! 🥰';
    } else if (happiness >= 75) {
      return 'Your pet is happy! 😊';
    } else if (happiness >= 50) {
      return 'Your pet is content 🙂';
    } else if (happiness >= 25) {
      return 'Your pet needs attention 😕';
    } else {
      return 'Your pet needs care! ⚠️';
    }
  }

  /// Get weekly summary message
  static String getWeeklySummaryMessage(int activitiesCompleted, int streak) {
    if (activitiesCompleted == 0) {
      return 'A fresh start awaits! Let\'s make this week count! 🌟';
    } else if (activitiesCompleted >= 50) {
      return 'Outstanding week! You\'re a pet care champion! 🏆';
    } else if (activitiesCompleted >= 30) {
      return 'Excellent dedication this week! 💪';
    } else if (activitiesCompleted >= 15) {
      return 'Good week of care! Keep it up! 🌟';
    } else {
      return 'Every activity counts! $activitiesCompleted tasks done! 👍';
    }
  }

  /// Get encouraging message for broken streak
  static String getBrokenStreakMessage() {
    final messages = [
      'Don\'t worry! Start a new streak today! 💪',
      'Every day is a new opportunity! Let\'s go! 🌟',
      'Setbacks happen. You\'ve got this! 🚀',
      'Fresh start! Your pet is counting on you! 🐾',
      'Back on track! One step at a time! ✨',
    ];
    return messages[_random.nextInt(messages.length)];
  }

  /// Get reminder to complete tasks
  static String getReminderMessage(int pendingTasks) {
    if (pendingTasks == 1) {
      return 'You have 1 task waiting! 🔔';
    } else if (pendingTasks <= 3) {
      return '$pendingTasks tasks ready! Quick win! ⚡';
    } else {
      return '$pendingTasks tasks pending. You can do this! 💪';
    }
  }

  /// Get level-up message
  static String getLevelUpMessage(int totalActivities) {
    if (totalActivities >= 1000) {
      return 'Master Level! 1000+ activities! 👑';
    } else if (totalActivities >= 500) {
      return 'Expert Level! 500+ activities! 🎓';
    } else if (totalActivities >= 100) {
      return 'Dedicated Level! 100+ activities! 💎';
    } else if (totalActivities >= 50) {
      return 'Committed Level! 50+ activities! ⭐';
    } else if (totalActivities >= 25) {
      return 'Consistent Level! 25+ activities! 🌟';
    } else if (totalActivities >= 10) {
      return 'Building Level! 10+ activities! 🔥';
    } else {
      return 'Started! $totalActivities activities! 🎯';
    }
  }

  // Private helper
  static String _getMessages(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  // Message collections
  static final List<String> _startMessages = [
    'Every journey begins with a single step! 🐾',
    'Your pet is excited for today\'s care! 🌟',
    'Let\'s build a great care routine! 💪',
    'Today is day one! Make it count! 🚀',
    'Small steps lead to big results! ✨',
  ];

  static final List<String> _buildingMessages = [
    'You\'re building momentum! 🔥',
    'Great start! Keep the streak alive! ⭐',
    'Your pet loves this consistency! 😊',
    'You\'re on the right track! 🎯',
    'Every day you\'re getting better! 💪',
  ];

  static final List<String> _goodMessages = [
    'Week strong! You\'re doing amazing! 🌟',
    'This streak shows true dedication! 💎',
    'Your pet is so lucky to have you! 🥰',
    'Consistency is your superpower! ⚡',
    'You\'re a care champion! 🏆',
  ];

  static final List<String> _greatMessages = [
    'A month of excellence! Incredible! 🎉',
    'Your dedication is inspiring! 👑',
    'Master-level pet parent! 🎓',
    '30 days of love and care! 💝',
    'You\'re setting the standard! ⭐',
  ];

  static final List<String> _masterMessages = [
    '100+ day streak! You\'re legendary! 👑',
    'Elite pet care master! 🏆',
    'Your commitment is extraordinary! 💎',
    'Hall of Fame material! 🌟',
    'Unbreakable dedication! 💪',
  ];

  static final List<String> _onTimeMessages = [
    'Perfect timing! 🎯',
    'Right on schedule! ⏰',
    'Excellent time management! ⭐',
    'Punctual care is quality care! 💚',
    'Your pet appreciates your timing! 😊',
  ];

  static final List<String> _lateMessages = [
    'Task complete! That\'s what matters! ✅',
    'Done is better than perfect! 💪',
    'Your pet is grateful! 🐾',
    'Completed! Way to follow through! 🌟',
    'Better late than never! Keep going! 🚀',
  ];

  /// Get tips based on care patterns
  static String getCarePatternTip(Map<String, int> dayActivity, List<int> hourActivity) {
    // Find least active day
    if (dayActivity.isNotEmpty) {
      final leastActiveDay = dayActivity.entries.reduce((a, b) => 
        a.value < b.value ? a : b
      ).key;
      
      if (dayActivity[leastActiveDay]! < 3) {
        return 'Tip: Try scheduling more care tasks on $leastActiveDay! 📅';
      }
    }
    
    // Check for morning/evening patterns
    final morningTotal = hourActivity.sublist(6, 12).reduce((a, b) => a + b);
    final eveningTotal = hourActivity.sublist(18, 22).reduce((a, b) => a + b);
    
    if (morningTotal < 5 && eveningTotal > morningTotal * 2) {
      return 'Tip: Morning routines help! Consider adding AM tasks! 🌅';
    }
    
    return 'Tip: Consistent timing helps build healthy habits! ⏰';
  }

  /// Get goal suggestion
  static String getGoalSuggestion(int currentStreak, int totalActivities) {
    if (currentStreak < 7) {
      return 'Goal: Reach a 7-day streak! 🎯';
    } else if (currentStreak < 30) {
      return 'Goal: Hit the 30-day milestone! 🏆';
    } else if (totalActivities < 100) {
      return 'Goal: Complete 100 total activities! 💯';
    } else if (totalActivities < 500) {
      return 'Goal: Reach expert status (500 activities)! 🎓';
    } else {
      return 'Goal: Achieve master level (1000 activities)! 👑';
    }
  }

  /// Get seasonal care reminder
  static String getSeasonalReminder() {
    final month = DateTime.now().month;
    
    if (month >= 3 && month <= 5) {
      // Spring
      return 'Spring Reminder: Check flea/tick prevention! 🌸';
    } else if (month >= 6 && month <= 8) {
      // Summer
      return 'Summer Care: Keep your pet cool & hydrated! ☀️';
    } else if (month >= 9 && month <= 11) {
      // Fall
      return 'Fall Care: Maintain parasite prevention! 🍂';
    } else {
      // Winter
      return 'Winter Care: Protect paws from ice & salt! ❄️';
    }
  }

  /// Get milestone congratulations
  static String getMilestoneCongrats(int days) {
    if (days == 7) {
      return '🎉 One week of amazing care! Keep it up!';
    } else if (days == 30) {
      return '🏆 One month milestone! You\'re incredible!';
    } else if (days == 100) {
      return '💎 100 days! You\'re a pet care legend!';
    } else if (days == 365) {
      return '👑 ONE YEAR! You\'re a true champion!';
    } else {
      return '⭐ $days days of consistent care! Amazing!';
    }
  }
}
