import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../services/database_service.dart';

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
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _selectedDoctorId = widget.selectedDoctorId;
    _selectedDoctorName = widget.selectedDoctorName;
    _selectedSpecialty = widget.selectedSpecialty;
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
    if (user == null ||
        _selectedStartTime == null ||
        _selectedDoctorId == null) {
      return false;
    }

    // 1. Check if USER has an appointment at the same time
    final userQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in userQuery.docs) {
      final existingAppointment = AppointmentModel.fromMap(doc.data(), doc.id);
      if (existingAppointment.startTime.isAtSameMomentAs(_selectedStartTime!) &&
          existingAppointment.status != 'cancelled') {
        return true;
      }
    }

    // 2. Check if DOCTOR has an appointment at the same time
    final doctorQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: _selectedDoctorId)
        .get();

    for (var doc in doctorQuery.docs) {
      final existingAppointment = AppointmentModel.fromMap(doc.data(), doc.id);
      if (existingAppointment.startTime.isAtSameMomentAs(_selectedStartTime!) &&
          existingAppointment.status != 'cancelled') {
        return true;
      }
    }

    return false;
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctorId == null ||
        _selectedStartTime == null ||
        _reasonController.text.isEmpty) {
      _showErrorDialog('Completa todos los campos');
      return;
    }

    if (await _checkOverlap()) {
      _showErrorDialog('Hay un conflicto con otra cita');
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
        reason: _reasonController.text,
        status: 'pending',
      );

      await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointment.toMap());

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Éxito'),
            content: const Text('Cita agendada'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
              ),
            ],
          ),
        );
      }
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
        middle: Text('Nueva Cita'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _selectedDoctorId == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Selecciona un especialista:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                          inherit: false,
                          fontFamily: '.SF Pro Display',
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<DoctorModel>>(
                        stream: _databaseService.getDoctors(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error al cargar doctores'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CupertinoActivityIndicator(),
                            );
                          }

                          final doctors = snapshot.data ?? [];

                          if (doctors.isEmpty) {
                            return const Center(
                              child: Text('No hay doctores disponibles'),
                            );
                          }

                          return CupertinoListSection.insetGrouped(
                            children: doctors.map((doctor) {
                              return CupertinoListTile(
                                leading: const Icon(
                                  CupertinoIcons.person_fill,
                                  color: CupertinoColors.activeBlue,
                                ),
                                title: Text(doctor.name),
                                subtitle: Text(doctor.specialty),
                                trailing: const Icon(
                                  CupertinoIcons.chevron_right,
                                  color: CupertinoColors.systemGrey3,
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedDoctorId = doctor.id;
                                    _selectedDoctorName = doctor.name;
                                    _selectedSpecialty = doctor.specialty;
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    CupertinoListSection.insetGrouped(
                      header: const Text('Detalles de la Cita'),
                      children: [
                        CupertinoListTile(
                          title: const Text('Doctor'),
                          subtitle: Text(_selectedDoctorName!),
                          leading: const Icon(CupertinoIcons.person_fill),
                        ),
                        CupertinoListTile(
                          title: const Text('Especialidad'),
                          subtitle: Text(_selectedSpecialty!),
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
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: _isLoading ? null : _bookAppointment,
                        child: _isLoading
                            ? const CupertinoActivityIndicator()
                            : const Text('Agendar Cita'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
