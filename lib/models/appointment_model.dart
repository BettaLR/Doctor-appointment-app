class AppointmentModel {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final DateTime startTime;
  final DateTime endTime;
  final String reason;
  final String status; // e.g., 'pending', 'confirmed', 'completed'

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.status,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      userId: data['userId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      specialty: data['specialty'] ?? '',
      startTime: DateTime.parse(data['startTime']),
      endTime: DateTime.parse(data['endTime']),
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'reason': reason,
      'status': status,
    };
  }
}
