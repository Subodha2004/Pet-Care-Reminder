import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/notification_history.dart';
import '../models/reminder_category.dart';

class NotificationHistoryDBHelper {
  static Database? _db;
  static const String dbName = 'notification_history.db';
  static const String tableName = 'notification_history';

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
            reminderId INTEGER NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            category INTEGER NOT NULL,
            scheduledTime TEXT NOT NULL,
            deliveredTime TEXT,
            actionTime TEXT,
            action INTEGER,
            actionDetails TEXT,
            wasDelivered INTEGER DEFAULT 0,
            wasSilenced INTEGER DEFAULT 0
          )
        ''');
        
        // Create indices for better query performance
        await db.execute(
          'CREATE INDEX idx_reminder_id ON $tableName(reminderId)'
        );
        await db.execute(
          'CREATE INDEX idx_scheduled_time ON $tableName(scheduledTime)'
        );
        await db.execute(
          'CREATE INDEX idx_delivered_time ON $tableName(deliveredTime)'
        );
      },
    );
    return _db!;
  }

  /// Insert a new notification history entry
  static Future<int> insertHistory(NotificationHistory history) async {
    final db = await getDb();
    return await db.insert(tableName, history.toMap());
  }

  /// Get all notification history entries
  static Future<List<NotificationHistory>> getAllHistory({
    int? limit,
    int? offset,
  }) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'scheduledTime DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) => NotificationHistory.fromMap(maps[i]));
  }

  /// Get history for a specific reminder
  static Future<List<NotificationHistory>> getHistoryByReminder(int reminderId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'reminderId = ?',
      whereArgs: [reminderId],
      orderBy: 'scheduledTime DESC',
    );
    return List.generate(maps.length, (i) => NotificationHistory.fromMap(maps[i]));
  }

  /// Get history by category
  static Future<List<NotificationHistory>> getHistoryByCategory(
    ReminderCategory category,
  ) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'category = ?',
      whereArgs: [category.index],
      orderBy: 'scheduledTime DESC',
    );
    return List.generate(maps.length, (i) => NotificationHistory.fromMap(maps[i]));
  }

  /// Get history within a date range
  static Future<List<NotificationHistory>> getHistoryByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'scheduledTime >= ? AND scheduledTime <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'scheduledTime DESC',
    );
    return List.generate(maps.length, (i) => NotificationHistory.fromMap(maps[i]));
  }

  /// Get delivered notifications only
  static Future<List<NotificationHistory>> getDeliveredHistory({
    int? limit,
  }) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'wasDelivered = ?',
      whereArgs: [1],
      orderBy: 'deliveredTime DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => NotificationHistory.fromMap(maps[i]));
  }

  /// Get silenced notifications (blocked by silent hours)
  static Future<List<NotificationHistory>> getSilencedHistory() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'wasSilenced = ?',
      whereArgs: [1],
      orderBy: 'scheduledTime DESC',
    );
    return List.generate(maps.length, (i) => NotificationHistory.fromMap(maps[i]));
  }

  /// Get history by action type
  static Future<List<NotificationHistory>> getHistoryByAction(
    NotificationAction action,
  ) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'action = ?',
      whereArgs: [action.index],
      orderBy: 'actionTime DESC',
    );
    return List.generate(maps.length, (i) => NotificationHistory.fromMap(maps[i]));
  }

  /// Update a notification history entry
  static Future<int> updateHistory(NotificationHistory history) async {
    final db = await getDb();
    return await db.update(
      tableName,
      history.toMap(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  /// Mark notification as delivered
  static Future<int> markAsDelivered(int id, {DateTime? deliveredTime}) async {
    final db = await getDb();
    return await db.update(
      tableName,
      {
        'wasDelivered': 1,
        'deliveredTime': (deliveredTime ?? DateTime.now()).toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Record notification action
  static Future<int> recordAction(
    int id,
    NotificationAction action, {
    String? actionDetails,
  }) async {
    final db = await getDb();
    return await db.update(
      tableName,
      {
        'action': action.index,
        'actionTime': DateTime.now().toIso8601String(),
        'actionDetails': actionDetails,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get statistics for a date range
  static Future<Map<String, dynamic>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await getDb();
    
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN wasDelivered = 1 THEN 1 ELSE 0 END) as delivered,
        SUM(CASE WHEN wasSilenced = 1 THEN 1 ELSE 0 END) as silenced,
        SUM(CASE WHEN action = ? THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN action = ? THEN 1 ELSE 0 END) as snoozed,
        SUM(CASE WHEN action = ? THEN 1 ELSE 0 END) as dismissed
      FROM $tableName
      WHERE scheduledTime >= ? AND scheduledTime <= ?
    ''', [
      NotificationAction.markedAsDone.index,
      NotificationAction.snoozed.index,
      NotificationAction.dismissed.index,
      start.toIso8601String(),
      end.toIso8601String(),
    ]);
    
    if (result.isEmpty) {
      return {
        'total': 0,
        'delivered': 0,
        'silenced': 0,
        'completed': 0,
        'snoozed': 0,
        'dismissed': 0,
      };
    }
    
    return result.first;
  }

  /// Get category statistics
  static Future<List<Map<String, dynamic>>> getCategoryStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await getDb();
    
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    return await db.rawQuery('''
      SELECT 
        category,
        COUNT(*) as count,
        SUM(CASE WHEN wasDelivered = 1 THEN 1 ELSE 0 END) as delivered
      FROM $tableName
      WHERE scheduledTime >= ? AND scheduledTime <= ?
      GROUP BY category
      ORDER BY count DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);
  }

  /// Delete a notification history entry
  static Future<int> deleteHistory(int id) async {
    final db = await getDb();
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete old history entries (older than specified days)
  static Future<int> deleteOldHistory(int daysToKeep) async {
    final db = await getDb();
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    return await db.delete(
      tableName,
      where: 'scheduledTime < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  /// Clear all notification history
  static Future<int> clearAllHistory() async {
    final db = await getDb();
    return await db.delete(tableName);
  }

  /// Close the database
  static Future<void> close() async {
    final db = await getDb();
    await db.close();
    _db = null;
  }
}
