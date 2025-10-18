import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pet_health.dart';

class PetHealthDBHelper {
  static Database? _db;
  static const String dbName = 'pet_health.db';

  static Future<Database> getDb() async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Vaccinations table
        await db.execute('''
          CREATE TABLE vaccinations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            petId INTEGER NOT NULL,
            vaccineName TEXT NOT NULL,
            dateGiven TEXT NOT NULL,
            nextDueDate TEXT,
            batchNumber TEXT,
            veterinarian TEXT,
            clinic TEXT,
            notes TEXT,
            certificatePath TEXT
          )
        ''');

        // Medical records table
        await db.execute('''
          CREATE TABLE medical_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            petId INTEGER NOT NULL,
            visitDate TEXT NOT NULL,
            visitType TEXT NOT NULL,
            diagnosis TEXT,
            treatment TEXT,
            prescription TEXT,
            cost REAL,
            veterinarian TEXT,
            clinic TEXT,
            notes TEXT,
            documentPath TEXT
          )
        ''');

        // Weight records table
        await db.execute('''
          CREATE TABLE weight_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            petId INTEGER NOT NULL,
            date TEXT NOT NULL,
            weight REAL NOT NULL,
            unit TEXT DEFAULT 'kg',
            notes TEXT
          )
        ''');

        // Medications table
        await db.execute('''
          CREATE TABLE medications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            petId INTEGER NOT NULL,
            medicationName TEXT NOT NULL,
            dosage TEXT,
            frequency TEXT,
            startDate TEXT NOT NULL,
            endDate TEXT,
            prescribedBy TEXT,
            notes TEXT,
            isActive INTEGER DEFAULT 1
          )
        ''');

        // Conditions/Allergies table
        await db.execute('''
          CREATE TABLE pet_conditions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            petId INTEGER NOT NULL,
            conditionType TEXT NOT NULL,
            name TEXT NOT NULL,
            severity TEXT,
            treatment TEXT,
            notes TEXT,
            diagnosedDate TEXT
          )
        ''');

        // Vet contacts table
        await db.execute('''
          CREATE TABLE vet_contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            petId INTEGER NOT NULL,
            clinicName TEXT NOT NULL,
            veterinarianName TEXT,
            phone TEXT,
            email TEXT,
            address TEXT,
            specialization TEXT,
            isPrimary INTEGER DEFAULT 0,
            notes TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  // ==================== VACCINATION METHODS ====================
  
  static Future<int> insertVaccination(Vaccination vaccination) async {
    final db = await getDb();
    return await db.insert('vaccinations', vaccination.toMap());
  }

  static Future<List<Vaccination>> getVaccinations(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'vaccinations',
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'dateGiven DESC',
    );
    return List.generate(maps.length, (i) => Vaccination.fromMap(maps[i]));
  }

  static Future<List<Vaccination>> getUpcomingVaccinations(int petId) async {
    final db = await getDb();
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'vaccinations',
      where: 'petId = ? AND nextDueDate IS NOT NULL AND nextDueDate >= ?',
      whereArgs: [petId, now],
      orderBy: 'nextDueDate ASC',
    );
    return List.generate(maps.length, (i) => Vaccination.fromMap(maps[i]));
  }

  static Future<int> updateVaccination(Vaccination vaccination) async {
    final db = await getDb();
    return await db.update(
      'vaccinations',
      vaccination.toMap(),
      where: 'id = ?',
      whereArgs: [vaccination.id],
    );
  }

  static Future<int> deleteVaccination(int id) async {
    final db = await getDb();
    return await db.delete('vaccinations', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== MEDICAL RECORD METHODS ====================
  
  static Future<int> insertMedicalRecord(MedicalRecord record) async {
    final db = await getDb();
    return await db.insert('medical_records', record.toMap());
  }

  static Future<List<MedicalRecord>> getMedicalRecords(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'medical_records',
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'visitDate DESC',
    );
    return List.generate(maps.length, (i) => MedicalRecord.fromMap(maps[i]));
  }

  static Future<int> updateMedicalRecord(MedicalRecord record) async {
    final db = await getDb();
    return await db.update(
      'medical_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  static Future<int> deleteMedicalRecord(int id) async {
    final db = await getDb();
    return await db.delete('medical_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== WEIGHT RECORD METHODS ====================
  
  static Future<int> insertWeightRecord(WeightRecord record) async {
    final db = await getDb();
    return await db.insert('weight_records', record.toMap());
  }

  static Future<List<WeightRecord>> getWeightRecords(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'weight_records',
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => WeightRecord.fromMap(maps[i]));
  }

  static Future<WeightRecord?> getLatestWeight(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'weight_records',
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'date DESC',
      limit: 1,
    );
    return maps.isNotEmpty ? WeightRecord.fromMap(maps.first) : null;
  }

  static Future<int> updateWeightRecord(WeightRecord record) async {
    final db = await getDb();
    return await db.update(
      'weight_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  static Future<int> deleteWeightRecord(int id) async {
    final db = await getDb();
    return await db.delete('weight_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== MEDICATION METHODS ====================
  
  static Future<int> insertMedication(Medication medication) async {
    final db = await getDb();
    return await db.insert('medications', medication.toMap());
  }

  static Future<List<Medication>> getMedications(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'startDate DESC',
    );
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }

  static Future<List<Medication>> getActiveMedications(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      where: 'petId = ? AND isActive = 1',
      whereArgs: [petId],
      orderBy: 'startDate DESC',
    );
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }

  static Future<int> updateMedication(Medication medication) async {
    final db = await getDb();
    return await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  static Future<int> deleteMedication(int id) async {
    final db = await getDb();
    return await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== CONDITION METHODS ====================
  
  static Future<int> insertCondition(PetCondition condition) async {
    final db = await getDb();
    return await db.insert('pet_conditions', condition.toMap());
  }

  static Future<List<PetCondition>> getConditions(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'pet_conditions',
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'diagnosedDate DESC',
    );
    return List.generate(maps.length, (i) => PetCondition.fromMap(maps[i]));
  }

  static Future<List<PetCondition>> getAllergies(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'pet_conditions',
      where: 'petId = ? AND conditionType = ?',
      whereArgs: [petId, 'Allergy'],
    );
    return List.generate(maps.length, (i) => PetCondition.fromMap(maps[i]));
  }

  static Future<int> updateCondition(PetCondition condition) async {
    final db = await getDb();
    return await db.update(
      'pet_conditions',
      condition.toMap(),
      where: 'id = ?',
      whereArgs: [condition.id],
    );
  }

  static Future<int> deleteCondition(int id) async {
    final db = await getDb();
    return await db.delete('pet_conditions', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== VET CONTACT METHODS ====================
  
  static Future<int> insertVetContact(VetContact contact) async {
    final db = await getDb();
    return await db.insert('vet_contacts', contact.toMap());
  }

  static Future<List<VetContact>> getVetContacts(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'vet_contacts',
      where: 'petId = ?',
      whereArgs: [petId],
      orderBy: 'isPrimary DESC, clinicName ASC',
    );
    return List.generate(maps.length, (i) => VetContact.fromMap(maps[i]));
  }

  static Future<VetContact?> getPrimaryVet(int petId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'vet_contacts',
      where: 'petId = ? AND isPrimary = 1',
      whereArgs: [petId],
      limit: 1,
    );
    return maps.isNotEmpty ? VetContact.fromMap(maps.first) : null;
  }

  static Future<int> updateVetContact(VetContact contact) async {
    final db = await getDb();
    return await db.update(
      'vet_contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  static Future<int> deleteVetContact(int id) async {
    final db = await getDb();
    return await db.delete('vet_contacts', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== UTILITY METHODS ====================
  
  /// Get health summary for a pet
  static Future<Map<String, int>> getHealthSummary(int petId) async {
    final vaccinations = await getVaccinations(petId);
    final medications = await getActiveMedications(petId);
    final conditions = await getConditions(petId);
    final medicalRecords = await getMedicalRecords(petId);
    
    return {
      'vaccinations': vaccinations.length,
      'activeMedications': medications.length,
      'conditions': conditions.length,
      'medicalVisits': medicalRecords.length,
    };
  }

  /// Close database
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
