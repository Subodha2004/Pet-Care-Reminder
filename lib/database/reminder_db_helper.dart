import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/reminder.dart';

class ReminderDBHelper {
  static Database? _db;
  static const String dbName = 'reminders_v2.db';
  static const String tableName = 'reminders';

  static Future<Database> getDb() async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            time TEXT NOT NULL,
            isActive INTEGER DEFAULT 1,
            petId INTEGER,
            recurrencePattern INTEGER DEFAULT 0,
            customIntervalValue INTEGER,
            customIntervalUnit INTEGER,
            weekdays TEXT,
            dayOfMonth INTEGER,
            startDate TEXT,
            endDate TEXT,
            lastTriggered TEXT,
            nextScheduled TEXT,
            snoozedUntil TEXT,
            snoozeCount INTEGER DEFAULT 0,
            autoAdjustForAge INTEGER DEFAULT 0,
            ageAdjustmentRule TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  /// Insert a new reminder
  static Future<int> insertReminder(Reminder reminder) async {
    final db = await getDb();
    return await db.insert(tableName, reminder.toMap());
  }

  /// Get all reminders
  static Future<List<Reminder>> getReminders() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'nextScheduled ASC, time ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  /// Get active reminders only
  static Future<List<Reminder>> getActiveReminders() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'nextScheduled ASC, time ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  /// Get reminders for a specific pet
  static Future<List<Reminder>> getRemindersByPet(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'nextScheduled ASC, time ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  /// Get upcoming reminders (within next 24 hours)
  static Future<List<Reminder>> getUpcomingReminders() async {
    final db = await getDb();
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isActive = ? AND nextScheduled IS NOT NULL AND nextScheduled <= ?',
      whereArgs: [1, tomorrow.toIso8601String()],
      orderBy: 'nextScheduled ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  /// Update a reminder
  static Future<int> updateReminder(Reminder reminder) async {
    final db = await getDb();
    return await db.update(
      tableName,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  /// Delete a reminder
  static Future<int> deleteReminder(int id) async {
    final db = await getDb();
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Snooze a reminder
  static Future<int> snoozeReminder(int id, Duration duration) async {
    final db = await getDb();
    final snoozedUntil = DateTime.now().add(duration);
    
    // Get current snooze count
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      columns: ['snoozeCount'],
      where: 'id = ?',
      whereArgs: [id],
    );
    
    final currentCount = result.isNotEmpty ? (result.first['snoozeCount'] as int?) ?? 0 : 0;
    
    return await db.update(
      tableName,
      {
        'snoozedUntil': snoozedUntil.toIso8601String(),
        'snoozeCount': currentCount + 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear snooze from a reminder
  static Future<int> clearSnooze(int id) async {
    final db = await getDb();
    return await db.update(
      tableName,
      {'snoozedUntil': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark reminder as triggered and calculate next occurrence
  static Future<int> triggerReminder(int id) async {
    final db = await getDb();
    final now = DateTime.now();
    
    // Get the reminder
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isEmpty) return 0;
    
    final reminder = Reminder.fromMap(result.first);
    final nextOccurrence = reminder.calculateNextOccurrence(from: now);
    
    return await db.update(
      tableName,
      {
        'lastTriggered': now.toIso8601String(),
        'nextScheduled': nextOccurrence?.toIso8601String(),
        'snoozedUntil': null, // Clear snooze when triggered
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Batch update next scheduled times for all active reminders
  static Future<void> updateAllScheduledTimes() async {
    final reminders = await getActiveReminders();
    final db = await getDb();
    
    for (final reminder in reminders) {
      if (reminder.nextScheduled == null) {
        final nextOccurrence = reminder.calculateNextOccurrence();
        if (nextOccurrence != null) {
          await db.update(
            tableName,
            {'nextScheduled': nextOccurrence.toIso8601String()},
            where: 'id = ?',
            whereArgs: [reminder.id],
          );
        }
      }
    }
  }

  /// Search reminders by title or description
  static Future<List<Reminder>> searchReminders(String query) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'nextScheduled ASC, time ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  /// Close the database
  static Future<void> close() async {
    final db = await getDb();
    await db.close();
    _db = null;
  }
}
