import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize doctors in Firestore
  Future<void> initializeDoctors() async {
    final doctors = [
      {'id': '1', 'name': 'Dr. Juan Pérez', 'specialty': 'Cardiología'},
      {'id': '2', 'name': 'Dra. María García', 'specialty': 'Dermatología'},
      {'id': '3', 'name': 'Dr. Carlos López', 'specialty': 'Neurología'},
      {'id': '4', 'name': 'Dra. Ana Rodríguez', 'specialty': 'Pediatría'},
      {'id': '5', 'name': 'Dr. Luis Martínez', 'specialty': 'Oftalmología'},
    ];

    for (var doctor in doctors) {
      await _firestore.collection('doctors').doc(doctor['id']).set({
        'name': doctor['name'],
        'specialty': doctor['specialty'],
      });
    }
  }

  // Get all doctors
  Stream<List<DoctorModel>> getDoctors() {
    return _firestore.collection('doctors').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DoctorModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Add a new doctor (for registered users with role 'Médico')
  Future<void> addDoctor(DoctorModel doctor) async {
    await _firestore.collection('doctors').doc(doctor.id).set(doctor.toMap());
  }

  // Check if user is a doctor and add to doctors collection if not exists
  Future<void> ensureDoctorExists(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userModel = UserModel.fromMap(userDoc.data()!, userDoc.id);
      if (userModel.role == 'Médico') {
        final doctorDoc = await _firestore
            .collection('doctors')
            .doc(userId)
            .get();
        if (!doctorDoc.exists) {
          // Create doctor entry with basic info, specialty can be updated later
          final doctor = DoctorModel(
            id: userId,
            name: userModel.name ?? userModel.email ?? 'Doctor',
            specialty: 'General', // Default specialty
          );
          await addDoctor(doctor);
        }
      }
    }
  }

  // Get doctor by ID
  Future<DoctorModel?> getDoctorById(String id) async {
    final doc = await _firestore.collection('doctors').doc(id).get();
    if (doc.exists) {
      return DoctorModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Get appointments for a specific doctor
  Stream<List<AppointmentModel>> getAppointmentsForDoctor(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AppointmentModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get total appointments for a doctor
  Future<int> getTotalAppointmentsForDoctor(String doctorId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .get();
    return snapshot.docs.length;
  }

  // Get pending appointments for a doctor
  Future<int> getPendingAppointmentsForDoctor(String doctorId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.length;
  }

  // Get total patients for a doctor (unique userIds in appointments)
  Future<int> getTotalPatientsForDoctor(String doctorId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .get();
    final userIds = snapshot.docs.map((doc) => doc['userId'] as String).toSet();
    return userIds.length;
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
