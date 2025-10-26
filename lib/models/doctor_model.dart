class DoctorModel {
  final String id;
  final String name;
  final String specialty;

  DoctorModel({required this.id, required this.name, required this.specialty});

  factory DoctorModel.fromMap(Map<String, dynamic> data, String id) {
    return DoctorModel(
      id: id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'specialty': specialty};
  }
}
