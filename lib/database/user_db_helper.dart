import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class UserDBHelper {
  static Database? _db;
  static const String dbName = 'users.db';
  static const String tableName = 'users';

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
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            email TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  /// Insert a new user into the database
  static Future<int> insertUser(User user) async {
    final db = await getDb();
    try {
      return await db.insert(tableName, user.toMap());
    } catch (e) {
      // Handle unique constraint violation (duplicate username)
      throw Exception('Username already exists');
    }
  }

  /// Get a user by username
  static Future<User?> getUserByUsername(String username) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return User.fromMap(maps.first);
  }

  /// Verify user credentials for login
  static Future<User?> verifyUser(String username, String password) async {
    final user = await getUserByUsername(username);
    
    if (user == null) {
      return null;
    }
    
    // Check if password matches
    if (user.password == password) {
      return user;
    }
    
    return null;
  }

  /// Check if username already exists
  static Future<bool> usernameExists(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  /// Get all users (for admin purposes)
  static Future<List<User>> getAllUsers() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  /// Update user information
  static Future<int> updateUser(User user) async {
    final db = await getDb();
    if (user.id == null) {
      throw ArgumentError('User id is required for update');
    }
    return await db.update(
      tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Delete a user
  static Future<int> deleteUser(int id) async {
    final db = await getDb();
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
