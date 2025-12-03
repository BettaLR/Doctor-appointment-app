import 'package:flutter/cupertino.dart';
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
  late TextEditingController _reasonController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStartTime = widget.appointment.startTime;
    _reasonController = TextEditingController(text: widget.appointment.reason);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: _selectedStartTime ?? DateTime.now(),
            mode: CupertinoDatePickerMode.dateAndTime,
            use24hFormat: true,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _selectedStartTime = newDate;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _checkOverlap() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedStartTime == null) return false;

    // 1. Check if USER has an appointment at the same time
    final userQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in userQuery.docs) {
      if (doc.id == widget.appointment.id) continue; // Skip current appointment
      final existingAppointment = AppointmentModel.fromMap(doc.data(), doc.id);
      if (existingAppointment.startTime.isAtSameMomentAs(_selectedStartTime!) &&
          existingAppointment.status != 'cancelled') {
        return true;
      }
    }

    // 2. Check if DOCTOR has an appointment at the same time
    final doctorQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.appointment.doctorId)
        .get();

    for (var doc in doctorQuery.docs) {
      if (doc.id == widget.appointment.id) continue; // Skip current appointment
      final existingAppointment = AppointmentModel.fromMap(doc.data(), doc.id);
      if (existingAppointment.startTime.isAtSameMomentAs(_selectedStartTime!) &&
          existingAppointment.status != 'cancelled') {
        return true;
      }
    }

    return false;
  }

  Future<void> _updateAppointment() async {
    if (_selectedStartTime == null || _reasonController.text.isEmpty) {
      _showErrorDialog('Completa todos los campos');
      return;
    }

    if (await _checkOverlap()) {
      _showErrorDialog('Hay un conflicto con otra cita');
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
      reason: _reasonController.text,
      status: widget.appointment.status,
    );

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointment.id)
        .update(updatedAppointment.toMap());

    if (mounted) {
      Navigator.pop(context);
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Editar Cita'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CupertinoListSection.insetGrouped(
                header: const Text('Detalles de la Cita'),
                children: [
                  CupertinoListTile(
                    title: const Text('Doctor'),
                    subtitle: Text(widget.appointment.doctorName),
                    leading: const Icon(CupertinoIcons.person_fill),
                  ),
                  CupertinoListTile(
                    title: const Text('Especialidad'),
                    subtitle: Text(widget.appointment.specialty),
                    leading: const Icon(CupertinoIcons.star_fill),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CupertinoTextField(
                controller: _reasonController,
                placeholder: 'Motivo de la consulta',
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                color: CupertinoColors.white,
                onPressed: _showDatePicker,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fecha y Hora',
                      style: TextStyle(color: CupertinoColors.black),
                    ),
                    Text(
                      _selectedStartTime != null
                          ? '${_selectedStartTime!.day}/${_selectedStartTime!.month}/${_selectedStartTime!.year} ${_selectedStartTime!.hour}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}'
                          : 'Seleccionar',
                      style: const TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _isLoading ? null : _updateAppointment,
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text('Actualizar Cita'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
