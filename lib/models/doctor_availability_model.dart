class DoctorAvailabilityModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final List<DateTime> availableSlots;

  DoctorAvailabilityModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.availableSlots,
  });

  factory DoctorAvailabilityModel.fromMap(
    Map<String, dynamic> data,
    String id,
  ) {
    return DoctorAvailabilityModel(
      id: id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      specialty: data['specialty'] ?? '',
      availableSlots:
          (data['availableSlots'] as List<dynamic>?)
              ?.map((slot) => DateTime.parse(slot))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'availableSlots': availableSlots
          .map((slot) => slot.toIso8601String())
          .toList(),
    };
  }
}
