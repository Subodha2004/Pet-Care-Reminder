import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/smart_suggestion.dart';

/// Database helper for smart suggestions
class SuggestionDBHelper {
  static Database? _db;
  static const String dbName = 'suggestions.db';
  static const String tableName = 'smart_suggestions';

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
            type INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            reason TEXT NOT NULL,
            priority INTEGER NOT NULL,
            source INTEGER NOT NULL,
            petId INTEGER,
            createdAt TEXT NOT NULL,
            expiresAt TEXT,
            isDismissed INTEGER DEFAULT 0,
            isAccepted INTEGER DEFAULT 0,
            metadata TEXT,
            actionType TEXT,
            actionData TEXT
          )
        ''');
        
        // Create index for faster queries
        await db.execute('CREATE INDEX idx_petId ON $tableName(petId)');
        await db.execute('CREATE INDEX idx_createdAt ON $tableName(createdAt)');
        await db.execute('CREATE INDEX idx_priority ON $tableName(priority)');
      },
    );
    return _db!;
  }

  /// Insert a new suggestion
  static Future<int> insertSuggestion(SmartSuggestion suggestion) async {
    final db = await getDb();
    return await db.insert(tableName, suggestion.toMap());
  }

  /// Batch insert suggestions
  static Future<void> insertSuggestions(List<SmartSuggestion> suggestions) async {
    final db = await getDb();
    final batch = db.batch();
    
    for (final suggestion in suggestions) {
      batch.insert(tableName, suggestion.toMap());
    }
    
    await batch.commit(noResult: true);
  }

  /// Get all active (valid) suggestions
  static Future<List<SmartSuggestion>> getActiveSuggestions() async {
    final db = await getDb();
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isDismissed = 0 AND isAccepted = 0 AND (expiresAt IS NULL OR expiresAt > ?)',
      whereArgs: [now],
      orderBy: 'priority DESC, createdAt DESC',
    );
    
    return List.generate(maps.length, (i) => SmartSuggestion.fromMap(maps[i]));
  }

  /// Get suggestions for a specific pet
  static Future<List<SmartSuggestion>> getSuggestionsByPet(int petId) async {
    final db = await getDb();
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'petId = ? AND isDismissed = 0 AND isAccepted = 0 AND (expiresAt IS NULL OR expiresAt > ?)',
      whereArgs: [petId, now],
      orderBy: 'priority DESC, createdAt DESC',
    );
    
    return List.generate(maps.length, (i) => SmartSuggestion.fromMap(maps[i]));
  }

  /// Get suggestions by type
  static Future<List<SmartSuggestion>> getSuggestionsByType(SuggestionType type) async {
    final db = await getDb();
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'type = ? AND isDismissed = 0 AND isAccepted = 0 AND (expiresAt IS NULL OR expiresAt > ?)',
      whereArgs: [type.index, now],
      orderBy: 'priority DESC, createdAt DESC',
    );
    
    return List.generate(maps.length, (i) => SmartSuggestion.fromMap(maps[i]));
  }

  /// Get high priority suggestions
  static Future<List<SmartSuggestion>> getHighPrioritySuggestions() async {
    final db = await getDb();
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'priority >= ? AND isDismissed = 0 AND isAccepted = 0 AND (expiresAt IS NULL OR expiresAt > ?)',
      whereArgs: [SuggestionPriority.high.index, now],
      orderBy: 'priority DESC, createdAt DESC',
    );
    
    return List.generate(maps.length, (i) => SmartSuggestion.fromMap(maps[i]));
  }

  /// Update a suggestion
  static Future<int> updateSuggestion(SmartSuggestion suggestion) async {
    final db = await getDb();
    return await db.update(
      tableName,
      suggestion.toMap(),
      where: 'id = ?',
      whereArgs: [suggestion.id],
    );
  }

  /// Mark suggestion as dismissed
  static Future<int> dismissSuggestion(int id) async {
    final db = await getDb();
    return await db.update(
      tableName,
      {'isDismissed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark suggestion as accepted
  static Future<int> acceptSuggestion(int id) async {
    final db = await getDb();
    return await db.update(
      tableName,
      {'isAccepted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a suggestion
  static Future<int> deleteSuggestion(int id) async {
    final db = await getDb();
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete expired suggestions
  static Future<int> deleteExpiredSuggestions() async {
    final db = await getDb();
    final now = DateTime.now().toIso8601String();
    
    return await db.delete(
      tableName,
      where: 'expiresAt IS NOT NULL AND expiresAt < ?',
      whereArgs: [now],
    );
  }

  /// Delete all dismissed and accepted suggestions older than specified days
  static Future<int> cleanOldSuggestions({int daysOld = 30}) async {
    final db = await getDb();
    final cutoffDate = DateTime.now()
        .subtract(Duration(days: daysOld))
        .toIso8601String();
    
    return await db.delete(
      tableName,
      where: '(isDismissed = 1 OR isAccepted = 1) AND createdAt < ?',
      whereArgs: [cutoffDate],
    );
  }

  /// Clear all suggestions (use with caution)
  static Future<int> clearAllSuggestions() async {
    final db = await getDb();
    return await db.delete(tableName);
  }

  /// Get suggestion count by status
  static Future<Map<String, int>> getSuggestionCounts() async {
    final db = await getDb();
    
    final active = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE isDismissed = 0 AND isAccepted = 0'
    );
    final dismissed = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE isDismissed = 1'
    );
    final accepted = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE isAccepted = 1'
    );
    
    return {
      'active': active.first['count'] as int,
      'dismissed': dismissed.first['count'] as int,
      'accepted': accepted.first['count'] as int,
    };
  }

  /// Refresh suggestions - clear old and insert new
  static Future<void> refreshSuggestions(List<SmartSuggestion> newSuggestions) async {
    final db = await getDb();
    
    // Delete old active suggestions
    await db.delete(
      tableName,
      where: 'isDismissed = 0 AND isAccepted = 0',
    );
    
    // Insert new suggestions
    await insertSuggestions(newSuggestions);
  }

  /// Close the database
  static Future<void> close() async {
    final db = await getDb();
    await db.close();
    _db = null;
  }
}
