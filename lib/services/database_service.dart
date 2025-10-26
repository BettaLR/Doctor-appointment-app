import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

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

  // Get doctor by ID
  Future<DoctorModel?> getDoctorById(String id) async {
    final doc = await _firestore.collection('doctors').doc(id).get();
    if (doc.exists) {
      return DoctorModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
