import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';
import '../models/doctor_availability_model.dart';

class NewAppointmentScreen extends StatefulWidget {
  final String? selectedDoctorId;
  final String? selectedDoctorName;
  final String? selectedSpecialty;

  const NewAppointmentScreen({
    super.key,
    this.selectedDoctorId,
    this.selectedDoctorName,
    this.selectedSpecialty,
  });

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  String? _selectedDoctorId;
  String? _selectedDoctorName;
  String? _selectedSpecialty;
  DateTime? _selectedStartTime;
  String _reason = '';
  bool _isLoading = false;

  final List<Map<String, String>> _specialists = [
    {'id': '1', 'name': 'Dr. Juan Pérez', 'specialty': 'Cardiología'},
    {'id': '2', 'name': 'Dra. María García', 'specialty': 'Dermatología'},
    {'id': '3', 'name': 'Dr. Carlos López', 'specialty': 'Neurología'},
    {'id': '4', 'name': 'Dra. Ana Rodríguez', 'specialty': 'Pediatría'},
    {'id': '5', 'name': 'Dr. Luis Martínez', 'specialty': 'Oftalmología'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDoctorId = widget.selectedDoctorId;
    _selectedDoctorName = widget.selectedDoctorName;
    _selectedSpecialty = widget.selectedSpecialty;
  }

  Future<void> _selectStartTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedStartTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<bool> _checkOverlap() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedStartTime == null) return false;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in querySnapshot.docs) {
      final existingAppointment = AppointmentModel.fromMap(doc.data(), doc.id);
      if (existingAppointment.startTime.isAtSameMomentAs(_selectedStartTime!)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctorId == null ||
        _selectedStartTime == null ||
        _reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    if (await _checkOverlap()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hay un conflicto con otra cita')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final appointment = AppointmentModel(
        id: '', // Firestore will generate
        userId: user.uid,
        doctorId: _selectedDoctorId!,
        doctorName: _selectedDoctorName!,
        specialty: _selectedSpecialty!,
        startTime: _selectedStartTime!,
        reason: _reason,
        status: 'pending',
      );

      await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointment.toMap());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cita agendada')));

      Navigator.pop(context);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cita'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedDoctorId == null) ...[
              const Text('Selecciona un especialista:'),
              Expanded(
                child: ListView.builder(
                  itemCount: _specialists.length,
                  itemBuilder: (context, index) {
                    final specialist = _specialists[index];
                    return ListTile(
                      title: Text(specialist['name']!),
                      subtitle: Text(specialist['specialty']!),
                      onTap: () {
                        setState(() {
                          _selectedDoctorId = specialist['id'];
                          _selectedDoctorName = specialist['name'];
                          _selectedSpecialty = specialist['specialty'];
                        });
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              Text('Doctor: $_selectedDoctorName'),
              Text('Especialidad: $_selectedSpecialty'),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Motivo de la consulta',
                ),
                onChanged: (value) => _reason = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectStartTime,
                child: Text(
                  _selectedStartTime == null
                      ? 'Seleccionar Hora de Inicio'
                      : 'Inicio: ${_selectedStartTime!.toLocal()}',
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _bookAppointment,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Agendar Cita'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
