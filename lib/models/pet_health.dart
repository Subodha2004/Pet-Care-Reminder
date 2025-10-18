/// Vaccination record model
class Vaccination {
  final int? id;
  final int petId;
  final String vaccineName;
  final DateTime dateGiven;
  final DateTime? nextDueDate;
  final String? batchNumber;
  final String? veterinarian;
  final String? clinic;
  final String? notes;
  final String? certificatePath; // Path to vaccination certificate

  Vaccination({
    this.id,
    required this.petId,
    required this.vaccineName,
    required this.dateGiven,
    this.nextDueDate,
    this.batchNumber,
    this.veterinarian,
    this.clinic,
    this.notes,
    this.certificatePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'vaccineName': vaccineName,
      'dateGiven': dateGiven.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'batchNumber': batchNumber,
      'veterinarian': veterinarian,
      'clinic': clinic,
      'notes': notes,
      'certificatePath': certificatePath,
    };
  }

  factory Vaccination.fromMap(Map<String, dynamic> map) {
    return Vaccination(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      vaccineName: map['vaccineName'] as String,
      dateGiven: DateTime.parse(map['dateGiven'] as String),
      nextDueDate: map['nextDueDate'] != null 
          ? DateTime.parse(map['nextDueDate'] as String) 
          : null,
      batchNumber: map['batchNumber'] as String?,
      veterinarian: map['veterinarian'] as String?,
      clinic: map['clinic'] as String?,
      notes: map['notes'] as String?,
      certificatePath: map['certificatePath'] as String?,
    );
  }

  bool get isOverdue {
    if (nextDueDate == null) return false;
    return DateTime.now().isAfter(nextDueDate!);
  }

  bool get isDueSoon {
    if (nextDueDate == null) return false;
    final now = DateTime.now();
    final diff = nextDueDate!.difference(now).inDays;
    return diff > 0 && diff <= 30; // Due within 30 days
  }
}

/// Medical record/visit model
class MedicalRecord {
  final int? id;
  final int petId;
  final DateTime visitDate;
  final String visitType; // Checkup, Emergency, Surgery, etc.
  final String? diagnosis;
  final String? treatment;
  final String? prescription;
  final double? cost;
  final String? veterinarian;
  final String? clinic;
  final String? notes;
  final String? documentPath; // Path to medical report

  MedicalRecord({
    this.id,
    required this.petId,
    required this.visitDate,
    required this.visitType,
    this.diagnosis,
    this.treatment,
    this.prescription,
    this.cost,
    this.veterinarian,
    this.clinic,
    this.notes,
    this.documentPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'visitDate': visitDate.toIso8601String(),
      'visitType': visitType,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'prescription': prescription,
      'cost': cost,
      'veterinarian': veterinarian,
      'clinic': clinic,
      'notes': notes,
      'documentPath': documentPath,
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      visitDate: DateTime.parse(map['visitDate'] as String),
      visitType: map['visitType'] as String,
      diagnosis: map['diagnosis'] as String?,
      treatment: map['treatment'] as String?,
      prescription: map['prescription'] as String?,
      cost: map['cost'] as double?,
      veterinarian: map['veterinarian'] as String?,
      clinic: map['clinic'] as String?,
      notes: map['notes'] as String?,
      documentPath: map['documentPath'] as String?,
    );
  }
}

/// Weight tracking model
class WeightRecord {
  final int? id;
  final int petId;
  final DateTime date;
  final double weight; // in kg
  final String? unit; // kg, lbs
  final String? notes;

  WeightRecord({
    this.id,
    required this.petId,
    required this.date,
    required this.weight,
    this.unit = 'kg',
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'weight': weight,
      'unit': unit,
      'notes': notes,
    };
  }

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      date: DateTime.parse(map['date'] as String),
      weight: map['weight'] as double,
      unit: map['unit'] as String? ?? 'kg',
      notes: map['notes'] as String?,
    );
  }
}

/// Medication schedule model
class Medication {
  final int? id;
  final int petId;
  final String medicationName;
  final String? dosage;
  final String? frequency; // e.g., "Twice daily", "Every 8 hours"
  final DateTime startDate;
  final DateTime? endDate;
  final String? prescribedBy;
  final String? notes;
  final bool isActive;

  Medication({
    this.id,
    required this.petId,
    required this.medicationName,
    this.dosage,
    this.frequency,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
    this.notes,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'prescribedBy': prescribedBy,
      'notes': notes,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      medicationName: map['medicationName'] as String,
      dosage: map['dosage'] as String?,
      frequency: map['frequency'] as String?,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null 
          ? DateTime.parse(map['endDate'] as String) 
          : null,
      prescribedBy: map['prescribedBy'] as String?,
      notes: map['notes'] as String?,
      isActive: (map['isActive'] as int?) == 1,
    );
  }

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }
}

/// Pet allergy/condition model
class PetCondition {
  final int? id;
  final int petId;
  final String conditionType; // Allergy, Chronic condition, etc.
  final String name;
  final String? severity; // Mild, Moderate, Severe
  final String? treatment;
  final String? notes;
  final DateTime? diagnosedDate;

  PetCondition({
    this.id,
    required this.petId,
    required this.conditionType,
    required this.name,
    this.severity,
    this.treatment,
    this.notes,
    this.diagnosedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'conditionType': conditionType,
      'name': name,
      'severity': severity,
      'treatment': treatment,
      'notes': notes,
      'diagnosedDate': diagnosedDate?.toIso8601String(),
    };
  }

  factory PetCondition.fromMap(Map<String, dynamic> map) {
    return PetCondition(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      conditionType: map['conditionType'] as String,
      name: map['name'] as String,
      severity: map['severity'] as String?,
      treatment: map['treatment'] as String?,
      notes: map['notes'] as String?,
      diagnosedDate: map['diagnosedDate'] != null 
          ? DateTime.parse(map['diagnosedDate'] as String) 
          : null,
    );
  }
}

/// Veterinarian contact model
class VetContact {
  final int? id;
  final int petId;
  final String clinicName;
  final String? veterinarianName;
  final String? phone;
  final String? email;
  final String? address;
  final String? specialization;
  final bool isPrimary;
  final String? notes;

  VetContact({
    this.id,
    required this.petId,
    required this.clinicName,
    this.veterinarianName,
    this.phone,
    this.email,
    this.address,
    this.specialization,
    this.isPrimary = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'clinicName': clinicName,
      'veterinarianName': veterinarianName,
      'phone': phone,
      'email': email,
      'address': address,
      'specialization': specialization,
      'isPrimary': isPrimary ? 1 : 0,
      'notes': notes,
    };
  }

  factory VetContact.fromMap(Map<String, dynamic> map) {
    return VetContact(
      id: map['id'] as int?,
      petId: map['petId'] as int,
      clinicName: map['clinicName'] as String,
      veterinarianName: map['veterinarianName'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      specialization: map['specialization'] as String?,
      isPrimary: (map['isPrimary'] as int?) == 1,
      notes: map['notes'] as String?,
    );
  }
}
