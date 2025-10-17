# 🛠️ Developer Quick Reference - Recurring Reminders

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                       UI Layer                          │
├─────────────────────────────────────────────────────────┤
│  main.dart                                              │
│  ├── PetCareHomePage (StatefulWidget)                   │
│  ├── _buildReminderCard()                               │
│  ├── _showSnoozeOptions()                               │
│  └── _showAddReminderDialog() -> Navigate               │
│                                                          │
│  add_edit_reminder_screen.dart                          │
│  └── AddEditReminderScreen                              │
│      ├── Pattern Selection                              │
│      ├── Dynamic Forms                                  │
│      └── Validation                                     │
├─────────────────────────────────────────────────────────┤
│                    Business Logic                       │
├─────────────────────────────────────────────────────────┤
│  models/reminder.dart                                   │
│  ├── RecurrencePattern (enum)                           │
│  ├── IntervalUnit (enum)                                │
│  └── Reminder (class)                                   │
│      ├── calculateNextOccurrence()                      │
│      ├── recurrenceDescription                          │
│      └── isSnoozed                                      │
├─────────────────────────────────────────────────────────┤
│                     Data Layer                          │
├─────────────────────────────────────────────────────────┤
│  database/reminder_db_helper.dart                       │
│  └── ReminderDBHelper                                   │
│      ├── CRUD Operations                                │
│      ├── Snooze Management                              │
│      └── Search & Filter                                │
└─────────────────────────────────────────────────────────┘
```

---

## 📦 Key Classes

### `Reminder` Model
```dart
// Create a daily reminder
final reminder = Reminder(
  id: DateTime.now().millisecondsSinceEpoch,
  title: "Feed Buddy",
  description: "Morning feeding",
  time: "08:00",
  recurrencePattern: RecurrencePattern.daily,
  isActive: true,
);

// Calculate next occurrence
final nextTime = reminder.calculateNextOccurrence();

// Get human-readable description
print(reminder.recurrenceDescription); // "Every day"

// Check if snoozed
if (reminder.isSnoozed) {
  print("Reminder is snoozed");
}
```

### `ReminderDBHelper` Usage
```dart
// Insert
await ReminderDBHelper.insertReminder(reminder);

// Get all
final reminders = await ReminderDBHelper.getReminders();

// Get active only
final active = await ReminderDBHelper.getActiveReminders();

// Get by pet
final petReminders = await ReminderDBHelper.getRemindersByPet(petId);

// Update
await ReminderDBHelper.updateReminder(updatedReminder);

// Delete
await ReminderDBHelper.deleteReminder(reminderId);

// Snooze
await ReminderDBHelper.snoozeReminder(
  reminderId,
  Duration(minutes: 15),
);

// Mark as triggered
await ReminderDBHelper.triggerReminder(reminderId);

// Search
final results = await ReminderDBHelper.searchReminders("feed");
```

---

## 🔄 Recurrence Pattern Examples

### Daily
```dart
Reminder(
  recurrencePattern: RecurrencePattern.daily,
  time: "08:00",
)
// Next: Tomorrow at 08:00
```

### Weekly
```dart
Reminder(
  recurrencePattern: RecurrencePattern.weekly,
  weekdays: [1, 3, 5], // Mon, Wed, Fri
  time: "18:00",
)
// Next: Next Mon/Wed/Fri at 18:00
```

### Monthly
```dart
Reminder(
  recurrencePattern: RecurrencePattern.monthly,
  dayOfMonth: 15,
  time: "10:00",
)
// Next: 15th of next month at 10:00
```

### Custom
```dart
Reminder(
  recurrencePattern: RecurrencePattern.custom,
  customIntervalValue: 3,
  customIntervalUnit: IntervalUnit.days,
  time: "09:00",
)
// Next: 3 days from now at 09:00
```

---

## 🎨 UI Components

### Show Add/Edit Screen
```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AddEditReminderScreen(
      reminder: existingReminder, // null for new
    ),
  ),
);

if (result != null && result is Reminder) {
  await ReminderDBHelper.insertReminder(result);
}
```

### Show Snooze Options
```dart
void _showSnoozeOptions(BuildContext context, Reminder reminder) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SnoozeOptionsSheet(
      onSelect: (duration) async {
        await ReminderDBHelper.snoozeReminder(
          reminder.id,
          duration,
        );
      },
    ),
  );
}
```

---

## 🗃️ Database Schema

```sql
CREATE TABLE reminders (
  -- Basic Info
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  time TEXT NOT NULL,              -- HH:mm format
  isActive INTEGER DEFAULT 1,
  petId INTEGER,
  
  -- Recurrence Configuration
  recurrencePattern INTEGER DEFAULT 0,  -- enum index
  customIntervalValue INTEGER,
  customIntervalUnit INTEGER,           -- enum index
  weekdays TEXT,                        -- comma-separated
  dayOfMonth INTEGER,                   -- 1-31
  
  -- Scheduling
  startDate TEXT,                       -- ISO8601
  endDate TEXT,                         -- ISO8601
  lastTriggered TEXT,                   -- ISO8601
  nextScheduled TEXT,                   -- ISO8601
  
  -- Snooze
  snoozedUntil TEXT,                    -- ISO8601
  snoozeCount INTEGER DEFAULT 0,
  
  -- Smart Features
  autoAdjustForAge INTEGER DEFAULT 0,
  ageAdjustmentRule TEXT                -- JSON
)
```

---

## 🔢 Enums

### RecurrencePattern
```dart
enum RecurrencePattern {
  none,     // 0 - One-time
  daily,    // 1 - Every day
  weekly,   // 2 - Specific weekdays
  monthly,  // 3 - Specific day of month
  custom,   // 4 - Custom interval
}
```

### IntervalUnit
```dart
enum IntervalUnit {
  days,     // 0
  weeks,    // 1
  months,   // 2
}
```

---

## 🧮 Next Occurrence Calculation Logic

```dart
DateTime? calculateNextOccurrence({DateTime? from}) {
  final baseDate = from ?? DateTime.now();
  
  // Parse time
  final timeParts = time.split(':');
  final hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);
  
  // Create next date
  DateTime nextDate = DateTime(
    baseDate.year,
    baseDate.month,
    baseDate.day,
    hour,
    minute,
  );
  
  // If past today, start tomorrow
  if (nextDate.isBefore(baseDate)) {
    nextDate = nextDate.add(Duration(days: 1));
  }
  
  switch (recurrencePattern) {
    case RecurrencePattern.daily:
      return nextDate;
      
    case RecurrencePattern.weekly:
      // Find next matching weekday
      for (int i = 0; i < 7; i++) {
        final checkDate = nextDate.add(Duration(days: i));
        if (weekdays!.contains(checkDate.weekday)) {
          return checkDate;
        }
      }
      return nextDate.add(Duration(days: 7));
      
    case RecurrencePattern.monthly:
      // Handle month transitions
      // ...
      
    case RecurrencePattern.custom:
      // Add custom interval
      // ...
  }
}
```

---

## 🎯 Common Tasks

### 1. Add New Recurrence Pattern
```dart
// 1. Add to enum
enum RecurrencePattern {
  // ... existing
  biweekly,  // New pattern
}

// 2. Handle in calculateNextOccurrence()
case RecurrencePattern.biweekly:
  return nextDate.add(Duration(days: 14));

// 3. Add UI in add_edit_reminder_screen.dart
_buildRecurrenceChip(
  'Bi-weekly',
  RecurrencePattern.biweekly,
  Icons.event_repeat,
)
```

### 2. Customize Recurrence Description
```dart
// In reminder.dart
String get recurrenceDescription {
  switch (recurrencePattern) {
    case RecurrencePattern.biweekly:
      return 'Every 2 weeks';
    // ...
  }
}
```

### 3. Add New Snooze Duration
```dart
// In main.dart _showSnoozeOptions()
_buildSnoozeOption(
  context,
  '4 hours',
  const Duration(hours: 4),
  reminder.id,
),
```

---

## 🐛 Common Issues & Solutions

### Issue: Next occurrence not calculated
**Solution**: Ensure `updateAllScheduledTimes()` is called on app start
```dart
await ReminderDBHelper.updateAllScheduledTimes();
```

### Issue: Snooze not persisting
**Solution**: Check database write permissions and error handling
```dart
try {
  await ReminderDBHelper.snoozeReminder(id, duration);
} catch (e) {
  print('Snooze error: $e');
}
```

### Issue: Weekly pattern showing wrong next date
**Solution**: Verify weekdays list is not empty and sorted
```dart
weekdays: (_selectedWeekdays.toList()..sort())
```

---

## 🧪 Testing Checklist

- [ ] Create daily reminder → Verify next = tomorrow
- [ ] Create weekly (Mon, Wed) → Verify next = next Mon or Wed
- [ ] Create monthly (day 15) → Verify next = 15th of next month
- [ ] Create custom (every 3 days) → Verify next = 3 days ahead
- [ ] Snooze reminder (15 min) → Verify badge appears
- [ ] Trigger reminder → Verify next occurrence recalculates
- [ ] Link to pet → Verify pet ID saved
- [ ] Enable age adjust → Verify flag stored
- [ ] Search reminder → Verify results correct
- [ ] Delete reminder → Verify removed from DB

---

## 📊 Performance Considerations

### Database Queries
```dart
// ✅ Good: Use specific queries
final active = await ReminderDBHelper.getActiveReminders();

// ❌ Bad: Filter in memory
final all = await ReminderDBHelper.getReminders();
final active = all.where((r) => r.isActive).toList();
```

### State Updates
```dart
// ✅ Good: Update only affected state
setState(() {
  _filteredReminders = newResults;
});

// ❌ Bad: Rebuild entire list
setState(() {
  _reminders = await ReminderDBHelper.getReminders();
  _filterReminders();
});
```

---

## 🔐 Security Notes

- ✅ Database stored locally (not cloud-synced)
- ✅ No sensitive data in reminder text
- ✅ Pet data access controlled
- ✅ No external API calls

---

## 🚀 Deployment Checklist

- [ ] Run `flutter pub get`
- [ ] Test on Android emulator
- [ ] Test on iOS simulator
- [ ] Verify database creation
- [ ] Test all recurrence patterns
- [ ] Test snooze functionality
- [ ] Check memory usage
- [ ] Profile database queries
- [ ] Verify no lint errors
- [ ] Update version number
- [ ] Build release APK/IPA

---

## 📞 Support & Resources

### Documentation
- `RECURRING_REMINDERS_GUIDE.md` - User guide
- `FEATURE_SUMMARY.md` - Implementation details
- This file - Developer reference

### Code Locations
- Models: `lib/models/reminder.dart`
- Database: `lib/database/reminder_db_helper.dart`
- UI: `lib/screens/add_edit_reminder_screen.dart`
- Main: `lib/main.dart`

---

**Quick Start Command**:
```bash
cd /path/to/pet_care_reminder
flutter pub get
flutter run
```

**Happy Coding! 🚀**
