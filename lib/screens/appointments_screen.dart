import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const CupertinoPageScaffold(
        child: Center(child: Text('Usuario no autenticado')),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mis Citas'),
        backgroundColor: CupertinoColors.white,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where(
              Filter.or(
                Filter('userId', isEqualTo: user.uid),
                Filter('doctorId', isEqualTo: user.uid),
              ),
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar citas'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final appointments = snapshot.data!.docs
              .map((doc) {
                return AppointmentModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );
              })
              .where((app) => app.status != 'completed')
              .toList(); // Filter out completed

          if (appointments.isEmpty) {
            return const Center(child: Text('No tienes citas pendientes'));
          }

          return CustomScrollView(
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                },
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final appointment = appointments[index];
                  final isDoctor = appointment.doctorId == user.uid;

                  return Dismissible(
                    key: Key(appointment.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      color: CupertinoColors.systemRed,
                      child: const Icon(
                        CupertinoIcons.delete,
                        color: CupertinoColors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      final confirm = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('Eliminar Cita'),
                          content: const Text(
                            '¿Estás seguro de que quieres eliminar esta cita?',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      return confirm ?? false;
                    },
                    onDismissed: (direction) async {
                      await FirebaseFirestore.instance
                          .collection('appointments')
                          .doc(appointment.id)
                          .delete();
                    },
                    child: GestureDetector(
                      onLongPress: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoActionSheet(
                            title: const Text('Opciones de Cita'),
                            actions: [
                              if (isDoctor && appointment.status != 'completed')
                                CupertinoActionSheetAction(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await FirebaseFirestore.instance
                                        .collection('appointments')
                                        .doc(appointment.id)
                                        .update({'status': 'completed'});
                                  },
                                  child: const Text('Marcar como Completada'),
                                ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/edit_appointment',
                                    arguments: appointment,
                                  );
                                },
                                child: const Text('Editar Cita'),
                              ),
                              CupertinoActionSheetAction(
                                isDestructiveAction: true,
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final confirm = await showCupertinoDialog<bool>(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Cancelar Cita'),
                                      content: const Text(
                                        '¿Estás seguro de que quieres cancelar esta cita?',
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          isDefaultAction: true,
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('No'),
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Sí'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await FirebaseFirestore.instance
                                        .collection('appointments')
                                        .doc(appointment.id)
                                        .update({'status': 'cancelled'});
                                  }
                                },
                                child: const Text('Cancelar Cita'),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/edit_appointment',
                          arguments: appointment,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withOpacity(
                                0.1,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: isDoctor
                              ? Border.all(
                                  color: CupertinoColors.activeBlue.withOpacity(
                                    0.3,
                                  ),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isDoctor
                                        ? 'Paciente (ID: ${appointment.userId.substring(0, 5)}...)'
                                        : '${appointment.doctorName} - ${appointment.specialty}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: CupertinoColors.black,
                                      inherit: false,
                                      fontFamily: '.SF Pro Text',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Inicio: ${appointment.startTime.toLocal()}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.systemGrey,
                                      inherit: false,
                                      fontFamily: '.SF Pro Text',
                                    ),
                                  ),
                                  Text(
                                    'Motivo: ${appointment.reason}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.systemGrey,
                                      inherit: false,
                                      fontFamily: '.SF Pro Text',
                                    ),
                                  ),
                                  Text(
                                    'Estado: ${appointment.status}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: appointment.status == 'cancelled'
                                          ? CupertinoColors.systemRed
                                          : appointment.status == 'completed'
                                          ? CupertinoColors.activeGreen
                                          : CupertinoColors.activeBlue,
                                      fontWeight: FontWeight.w500,
                                      inherit: false,
                                      fontFamily: '.SF Pro Text',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              CupertinoIcons.chevron_right,
                              color: CupertinoColors.systemGrey3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: appointments.length),
              ),
            ],
          );
        },
      ),
    );
  }
}
