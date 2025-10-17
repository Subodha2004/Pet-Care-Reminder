class Pet{
  int? id;
  String name;
  int age;
  String? photo;
  String? notes;

  Pet({
    this.id,
    required this.name,
    required this.age,
    this.photo,
    this.notes,
});
  Map<String,dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'age': age,
      'photo': photo,
      'notes': notes,
    };
  }
    factory Pet.fromMap(Map<String,dynamic>map){
    return Pet(
      id:map['id'],
      name:map['name'],
      age:map['age'],
      photo:map['photo'],
      notes:map['notes'],
    );

    }
  }

