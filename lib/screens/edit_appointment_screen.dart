import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';

class EditAppointmentScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const EditAppointmentScreen({super.key, required this.appointment});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  late DateTime? _selectedStartTime;
  late DateTime? _selectedEndTime;
  late String _reason;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStartTime = widget.appointment.startTime;
    _selectedEndTime = widget.appointment.endTime;
    _reason = widget.appointment.reason;
  }

  Future<void> _selectStartTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedStartTime ?? DateTime.now(),
        ),
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

  Future<void> _selectEndTime() async {
    if (_selectedStartTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona primero la hora de inicio')),
      );
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedEndTime ?? _selectedStartTime!.add(const Duration(hours: 1)),
      ),
    );

    if (pickedTime != null) {
      final endTime = DateTime(
        _selectedStartTime!.year,
        _selectedStartTime!.month,
        _selectedStartTime!.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      if (endTime.isBefore(_selectedStartTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La hora de fin debe ser después de la hora de inicio',
            ),
          ),
        );
        return;
      }

      setState(() {
        _selectedEndTime = endTime;
      });
    }
  }

  Future<bool> _checkOverlap() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedStartTime == null || _selectedEndTime == null)
      return false;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.id == widget.appointment.id) continue; // Skip current appointment
      final existingAppointment = AppointmentModel.fromMap(doc.data(), doc.id);
      if (existingAppointment.startTime.isBefore(_selectedEndTime!) &&
          existingAppointment.endTime.isAfter(_selectedStartTime!)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _updateAppointment() async {
    if (_selectedStartTime == null ||
        _selectedEndTime == null ||
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

    final updatedAppointment = AppointmentModel(
      id: widget.appointment.id,
      userId: widget.appointment.userId,
      doctorId: widget.appointment.doctorId,
      doctorName: widget.appointment.doctorName,
      specialty: widget.appointment.specialty,
      startTime: _selectedStartTime!,
      endTime: _selectedEndTime!,
      reason: _reason,
      status: widget.appointment.status,
    );

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointment.id)
        .update(updatedAppointment.toMap());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cita actualizada')));

    Navigator.pop(context);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cita'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Doctor: ${widget.appointment.doctorName}'),
            Text('Especialidad: ${widget.appointment.specialty}'),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Motivo de la consulta',
              ),
              controller: TextEditingController(text: _reason),
              onChanged: (value) => _reason = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectStartTime,
              child: Text('Inicio: ${_selectedStartTime!.toLocal()}'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _selectEndTime,
              child: Text('Fin: ${_selectedEndTime!.toLocal()}'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateAppointment,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Actualizar Cita'),
            ),
          ],
        ),
      ),
    );
  }
}
