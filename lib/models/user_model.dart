class UserModel {
  final String id;
  final String email;
  final String? name;
  final int? age;
  final String? birthplace;
  final String? conditions;
  final String role; // 'Paciente' or 'Médico'

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.age,
    this.birthplace,
    this.conditions,
    this.role = 'Paciente', // Default role
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'],
      age: data['age'],
      birthplace: data['birthplace'],
      conditions: data['conditions'],
      role: data['role'] ?? 'Paciente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'birthplace': birthplace,
      'conditions': conditions,
      'role': role,
    };
  }
}
