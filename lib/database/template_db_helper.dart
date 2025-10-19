import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/reminder_template.dart';

class TemplateDBHelper {
  static Database? _db;
  static const String dbName = 'reminder_templates.db';
  static const String tableName = 'reminder_templates';

  static Future<Database> getDb() async {
    if (_db != null) return _db!;
    String path = p.join(await getDatabasesPath(), dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            time TEXT NOT NULL,
            category INTEGER DEFAULT 7,
            recurrencePattern INTEGER DEFAULT 0,
            customIntervalValue INTEGER,
            customIntervalUnit INTEGER,
            weekdays TEXT,
            dayOfMonth INTEGER,
            autoAdjustForAge INTEGER DEFAULT 0,
            notificationPriority INTEGER DEFAULT 1,
            notificationSound INTEGER DEFAULT 0,
            advanceReminderMinutes INTEGER,
            enableAdvanceReminder INTEGER DEFAULT 0,
            petId INTEGER,
            petGroup TEXT,
            isGlobal INTEGER DEFAULT 1
          )
        ''');

        // Insert default templates
        final defaultTemplates = ReminderTemplate.getDefaultTemplates();
        for (final template in defaultTemplates) {
          await db.insert(tableName, template.toMap());
        }
      },
    );
    return _db!;
  }

  /// Insert a new template
  static Future<int> insertTemplate(ReminderTemplate template) async {
    final db = await getDb();
    return await db.insert(tableName, template.toMap());
  }

  /// Get all templates
  static Future<List<ReminderTemplate>> getTemplates() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'isGlobal DESC, name ASC',
    );
    return List.generate(maps.length, (i) => ReminderTemplate.fromMap(maps[i]));
  }

  /// Get global templates (available for all pets)
  static Future<List<ReminderTemplate>> getGlobalTemplates() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isGlobal = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ReminderTemplate.fromMap(maps[i]));
  }

  /// Get templates for a specific pet
  static Future<List<ReminderTemplate>> getTemplatesForPet(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isGlobal = ? OR petId = ?',
      whereArgs: [1, petId],
      orderBy: 'isGlobal DESC, name ASC',
    );
    return List.generate(maps.length, (i) => ReminderTemplate.fromMap(maps[i]));
  }

  /// Get templates for a pet group
  static Future<List<ReminderTemplate>> getTemplatesForGroup(String group) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isGlobal = ? OR petGroup = ?',
      whereArgs: [1, group],
      orderBy: 'isGlobal DESC, name ASC',
    );
    return List.generate(maps.length, (i) => ReminderTemplate.fromMap(maps[i]));
  }

  /// Get templates by category
  static Future<List<ReminderTemplate>> getTemplatesByCategory(int categoryIndex) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'category = ?',
      whereArgs: [categoryIndex],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ReminderTemplate.fromMap(maps[i]));
  }

  /// Update a template
  static Future<int> updateTemplate(ReminderTemplate template) async {
    final db = await getDb();
    if (template.id == null) {
      throw ArgumentError('Template id is required for update');
    }
    return await db.update(
      tableName,
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  /// Delete a template
  static Future<int> deleteTemplate(int id) async {
    final db = await getDb();
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Search templates by name or title
  static Future<List<ReminderTemplate>> searchTemplates(String query) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'name LIKE ? OR title LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'isGlobal DESC, name ASC',
    );
    return List.generate(maps.length, (i) => ReminderTemplate.fromMap(maps[i]));
  }

  /// Reset to default templates
  static Future<void> resetToDefaults() async {
    final db = await getDb();
    await db.delete(tableName);
    
    final defaultTemplates = ReminderTemplate.getDefaultTemplates();
    for (final template in defaultTemplates) {
      await db.insert(tableName, template.toMap());
    }
  }

  /// Close the database
  static Future<void> close() async {
    final db = await getDb();
    await db.close();
    _db = null;
  }
}
