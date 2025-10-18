import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/care_activity.dart';
import '../models/reminder_category.dart';

class CareActivityDBHelper {
  static Database? _db;
  static const String dbName = 'care_activities.db';
  static const String activitiesTable = 'care_activities';
  static const String achievementsTable = 'achievements';

  static Future<Database> getDb() async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Care activities table
        await db.execute('''
          CREATE TABLE $activitiesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reminderId INTEGER NOT NULL,
            petId INTEGER,
            title TEXT NOT NULL,
            description TEXT,
            category INTEGER NOT NULL,
            completedAt TEXT NOT NULL,
            scheduledTime TEXT NOT NULL,
            notes TEXT,
            durationMinutes INTEGER,
            metadata TEXT,
            photoPath TEXT,
            wasOnTime INTEGER DEFAULT 1
          )
        ''');

        // Achievements table
        await db.execute('''
          CREATE TABLE $achievementsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type INTEGER NOT NULL UNIQUE,
            earnedAt TEXT NOT NULL,
            isNew INTEGER DEFAULT 1
          )
        ''');

        // Create indices for better performance
        await db.execute(
          'CREATE INDEX idx_completed_at ON $activitiesTable(completedAt)'
        );
        await db.execute(
          'CREATE INDEX idx_category ON $activitiesTable(category)'
        );
        await db.execute(
          'CREATE INDEX idx_pet_id ON $activitiesTable(petId)'
        );
        await db.execute(
          'CREATE INDEX idx_reminder_id ON $activitiesTable(reminderId)'
        );
      },
    );
    return _db!;
  }

  /// Insert a new activity
  static Future<int> insertActivity(CareActivity activity) async {
    final db = await getDb();
    return await db.insert(activitiesTable, activity.toMap());
  }

  /// Get all activities
  static Future<List<CareActivity>> getAllActivities({
    int? limit,
    int? offset,
  }) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      activitiesTable,
      orderBy: 'completedAt DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) => CareActivity.fromMap(maps[i]));
  }

  /// Get activities by pet
  static Future<List<CareActivity>> getActivitiesByPet(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      activitiesTable,
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'completedAt DESC',
    );
    return List.generate(maps.length, (i) => CareActivity.fromMap(maps[i]));
  }

  /// Get activities by category
  static Future<List<CareActivity>> getActivitiesByCategory(
    ReminderCategory category,
  ) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      activitiesTable,
      where: 'category = ?',
      whereArgs: [category.index],
      orderBy: 'completedAt DESC',
    );
    return List.generate(maps.length, (i) => CareActivity.fromMap(maps[i]));
  }

  /// Get activities by date range
  static Future<List<CareActivity>> getActivitiesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      activitiesTable,
      where: 'completedAt >= ? AND completedAt <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'completedAt DESC',
    );
    return List.generate(maps.length, (i) => CareActivity.fromMap(maps[i]));
  }

  /// Get activities for today
  static Future<List<CareActivity>> getTodayActivities() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getActivitiesByDateRange(startOfDay, endOfDay);
  }

  /// Get activities for this week
  static Future<List<CareActivity>> getWeekActivities() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return getActivitiesByDateRange(startOfDay, now);
  }

  /// Get activities for this month
  static Future<List<CareActivity>> getMonthActivities() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getActivitiesByDateRange(startOfMonth, now);
  }

  /// Update an activity
  static Future<int> updateActivity(CareActivity activity) async {
    final db = await getDb();
    return await db.update(
      activitiesTable,
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  /// Delete an activity
  static Future<int> deleteActivity(int id) async {
    final db = await getDb();
    return await db.delete(
      activitiesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get statistics for a category or overall
  static Future<ActivityStatistics> getStatistics({
    ReminderCategory? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await getDb();
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (category != null) {
      whereClause = 'category = ?';
      whereArgs.add(category.index);
    }
    
    if (startDate != null && endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'completedAt >= ? AND completedAt <= ?';
      whereArgs.addAll([startDate.toIso8601String(), endDate.toIso8601String()]);
    }
    
    // Get basic stats
    final statsQuery = '''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN wasOnTime = 1 THEN 1 ELSE 0 END) as onTimeCount,
        SUM(CASE WHEN wasOnTime = 0 THEN 1 ELSE 0 END) as lateCount,
        AVG(durationMinutes) as avgDuration,
        MAX(completedAt) as lastActivity
      FROM $activitiesTable
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
    ''';
    
    final statsResult = await db.rawQuery(statsQuery, whereArgs);
    final stats = statsResult.first;
    
    // Get activity count by day of week
    final dayQuery = '''
      SELECT 
        CAST(strftime('%w', completedAt) AS INTEGER) as dayOfWeek,
        COUNT(*) as count
      FROM $activitiesTable
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      GROUP BY dayOfWeek
    ''';
    
    final dayResults = await db.rawQuery(dayQuery, whereArgs);
    final activityCountByDay = <String, int>{};
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    for (final row in dayResults) {
      final dayIndex = row['dayOfWeek'] as int;
      final count = row['count'] as int;
      activityCountByDay[dayNames[dayIndex]] = count;
    }
    
    // Get activity count by hour
    final hourQuery = '''
      SELECT 
        CAST(strftime('%H', completedAt) AS INTEGER) as hour,
        COUNT(*) as count
      FROM $activitiesTable
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      GROUP BY hour
    ''';
    
    final hourResults = await db.rawQuery(hourQuery, whereArgs);
    final activityCountByHour = List<int>.filled(24, 0);
    
    for (final row in hourResults) {
      final hour = row['hour'] as int;
      final count = row['count'] as int;
      activityCountByHour[hour] = count;
    }
    
    // Calculate streaks
    final streaks = await _calculateStreaks(category);
    
    return ActivityStatistics(
      category: category,
      totalActivities: stats['total'] as int,
      onTimeCount: stats['onTimeCount'] as int,
      lateCount: stats['lateCount'] as int,
      averageDurationMinutes: (stats['avgDuration'] as num?)?.toDouble() ?? 0.0,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
      lastActivityDate: stats['lastActivity'] != null 
          ? DateTime.parse(stats['lastActivity'] as String) 
          : null,
      activityCountByDay: activityCountByDay,
      activityCountByHour: activityCountByHour,
    );
  }

  /// Calculate current and longest streaks
  static Future<Map<String, int>> _calculateStreaks(ReminderCategory? category) async {
    final db = await getDb();
    
    String whereClause = category != null ? 'WHERE category = ?' : '';
    List<dynamic> whereArgs = category != null ? [category.index] : [];
    
    // Get all activity dates
    final query = '''
      SELECT DISTINCT DATE(completedAt) as activityDate
      FROM $activitiesTable
      $whereClause
      ORDER BY activityDate DESC
    ''';
    
    final results = await db.rawQuery(query, whereArgs);
    
    if (results.isEmpty) {
      return {'current': 0, 'longest': 0};
    }
    
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    
    DateTime? previousDate;
    
    for (int i = 0; i < results.length; i++) {
      final dateStr = results[i]['activityDate'] as String;
      final date = DateTime.parse(dateStr);
      
      if (i == 0) {
        // Check if most recent activity is today or yesterday
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        
        if (_isSameDay(date, today) || _isSameDay(date, yesterday)) {
          currentStreak = 1;
        }
        previousDate = date;
        continue;
      }
      
      if (previousDate != null) {
        final diff = previousDate.difference(date).inDays;
        
        if (diff == 1) {
          tempStreak++;
          if (i == 1) currentStreak = tempStreak;
        } else {
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 1;
        }
      }
      
      previousDate = date;
    }
    
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }
    
    return {'current': currentStreak, 'longest': longestStreak};
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get category breakdown for a date range
  static Future<Map<ReminderCategory, int>> getCategoryBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await getDb();
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (startDate != null && endDate != null) {
      whereClause = 'WHERE completedAt >= ? AND completedAt <= ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }
    
    final query = '''
      SELECT category, COUNT(*) as count
      FROM $activitiesTable
      $whereClause
      GROUP BY category
    ''';
    
    final results = await db.rawQuery(query, whereArgs);
    final breakdown = <ReminderCategory, int>{};
    
    for (final row in results) {
      final category = ReminderCategory.values[row['category'] as int];
      final count = row['count'] as int;
      breakdown[category] = count;
    }
    
    return breakdown;
  }

  /// Achievement methods
  static Future<int> insertAchievement(Achievement achievement) async {
    final db = await getDb();
    return await db.insert(
      achievementsTable,
      achievement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<Achievement>> getAllAchievements() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      achievementsTable,
      orderBy: 'earnedAt DESC',
    );
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  static Future<List<Achievement>> getNewAchievements() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      achievementsTable,
      where: 'isNew = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  static Future<int> markAchievementAsSeen(int id) async {
    final db = await getDb();
    return await db.update(
      achievementsTable,
      {'isNew': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<bool> hasAchievement(AchievementType type) async {
    final db = await getDb();
    final result = await db.query(
      achievementsTable,
      where: 'type = ?',
      whereArgs: [type.index],
    );
    return result.isNotEmpty;
  }

  /// Check and award achievements
  static Future<List<Achievement>> checkAndAwardAchievements() async {
    final newAchievements = <Achievement>[];
    final stats = await getStatistics();
    
    // First activity
    if (stats.totalActivities >= 1 && !await hasAchievement(AchievementType.firstActivity)) {
      final achievement = Achievement(
        id: 0,
        type: AchievementType.firstActivity,
        earnedAt: DateTime.now(),
        isNew: true,
      );
      await insertAchievement(achievement);
      newAchievements.add(achievement);
    }
    
    // Streak achievements
    if (stats.currentStreak >= 7 && !await hasAchievement(AchievementType.streak7Days)) {
      final achievement = Achievement(
        id: 0,
        type: AchievementType.streak7Days,
        earnedAt: DateTime.now(),
        isNew: true,
      );
      await insertAchievement(achievement);
      newAchievements.add(achievement);
    }
    
    if (stats.currentStreak >= 30 && !await hasAchievement(AchievementType.streak30Days)) {
      final achievement = Achievement(
        id: 0,
        type: AchievementType.streak30Days,
        earnedAt: DateTime.now(),
        isNew: true,
      );
      await insertAchievement(achievement);
      newAchievements.add(achievement);
    }
    
    if (stats.currentStreak >= 100 && !await hasAchievement(AchievementType.streak100Days)) {
      final achievement = Achievement(
        id: 0,
        type: AchievementType.streak100Days,
        earnedAt: DateTime.now(),
        isNew: true,
      );
      await insertAchievement(achievement);
      newAchievements.add(achievement);
    }
    
    // Total activity achievements
    if (stats.totalActivities >= 100 && !await hasAchievement(AchievementType.dedicated)) {
      final achievement = Achievement(
        id: 0,
        type: AchievementType.dedicated,
        earnedAt: DateTime.now(),
        isNew: true,
      );
      await insertAchievement(achievement);
      newAchievements.add(achievement);
    }
    
    if (stats.totalActivities >= 500 && !await hasAchievement(AchievementType.expert)) {
      final achievement = Achievement(
        id: 0,
        type: AchievementType.expert,
        earnedAt: DateTime.now(),
        isNew: true,
      );
      await insertAchievement(achievement);
      newAchievements.add(achievement);
    }
    
    if (stats.totalActivities >= 1000 && !await hasAchievement(AchievementType.master)) {
      final achievement = Achievement(
        id: 0,
        type: AchievementType.master,
        earnedAt: DateTime.now(),
        isNew: true,
      );
      await insertAchievement(achievement);
      newAchievements.add(achievement);
    }
    
    // Time-based achievements
    final morningCount = stats.activityCountByHour.sublist(5, 9).reduce((a, b) => a + b);
    if (morningCount >= 50 && !await hasAchievement(AchievementType.earlyBird)) {
      final achievement = Achievement(
        id: 0,
        type: AchievementType.earlyBird,
        earnedAt: DateTime.now(),
        isNew: true,
      );
      await insertAchievement(achievement);
      newAchievements.add(achievement);
    }
    
    final nightCount = stats.activityCountByHour.sublist(21, 24).reduce((a, b) => a + b);
    if (nightCount >= 50 && !await hasAchievement(AchievementType.nightOwl)) {
      final achievement = Achievement(
        id: 0,
        type: AchievementType.nightOwl,
        earnedAt: DateTime.now(),
        isNew: true,
      );
      await insertAchievement(achievement);
      newAchievements.add(achievement);
    }
    
    return newAchievements;
  }

  /// Delete old activities
  static Future<int> deleteOldActivities(int daysToKeep) async {
    final db = await getDb();
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    return await db.delete(
      activitiesTable,
      where: 'completedAt < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  /// Close the database
  static Future<void> close() async {
    final db = await getDb();
    await db.close();
    _db = null;
  }
}
