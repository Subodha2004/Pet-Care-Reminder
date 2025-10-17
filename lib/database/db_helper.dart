import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pet.dart';

class DBHelper {
  static Database? _db;
  static const String dbName = 'pets.db';

  static Future<Database> getDb() async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), dbName);
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE pets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          age INTEGER,
          photo TEXT,
          notes TEXT
        )
      ''');
    });
    return _db!;
  }

  static Future<int> insertPet(Pet pet) async {
    final db = await getDb();
    return await db.insert('pets', pet.toMap());
  }

  static Future<List<Pet>> getPets() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('pets');
    return List.generate(maps.length, (i) => Pet.fromMap(maps[i]));
  }

  static Future<int> updatePet(Pet pet) async {
    final db = await getDb();
    if (pet.id == null) {
      throw ArgumentError('Pet id is required for update');
    }
    return await db.update('pets', pet.toMap(), where: 'id = ?', whereArgs: [pet.id]);
  }

  static Future<int> deletePet(int id) async {
    final db = await getDb();
    return await db.delete('pets', where: 'id = ?', whereArgs: [id]);
  }
}