class UserModel {
  final String id;
  final String email;
  final String? name;
  final int? age;
  final String? birthplace;
  final String? conditions;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.age,
    this.birthplace,
    this.conditions,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'],
      age: data['age'],
      birthplace: data['birthplace'],
      conditions: data['conditions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'birthplace': birthplace,
      'conditions': conditions,
    };
  }
}
