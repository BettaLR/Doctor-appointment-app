import 'package:flutter/cupertino.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Sobre Nosotros'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Icon(
                CupertinoIcons.heart_fill,
                size: 80,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Doctor Appointment App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                  inherit: false,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Versión 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Nuestra Misión',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Facilitar el acceso a servicios médicos de calidad, conectando pacientes con profesionales de la salud de manera eficiente y segura.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 32),
              CupertinoListSection.insetGrouped(
                header: const Text('Características Principales'),
                children: const [
                  CupertinoListTile(
                    leading: Icon(
                      CupertinoIcons.calendar,
                      color: CupertinoColors.activeBlue,
                    ),
                    title: Text('Agendamiento de Citas'),
                    subtitle: Text(
                      'Programa citas con especialistas fácilmente',
                    ),
                  ),
                  CupertinoListTile(
                    leading: Icon(
                      CupertinoIcons.person,
                      color: CupertinoColors.activeBlue,
                    ),
                    title: Text('Perfiles Personales'),
                    subtitle: Text(
                      'Gestiona tu información médica de forma segura',
                    ),
                  ),
                  CupertinoListTile(
                    leading: Icon(
                      CupertinoIcons.bell,
                      color: CupertinoColors.activeBlue,
                    ),
                    title: Text('Recordatorios'),
                    subtitle: Text('Recibe notificaciones de tus citas'),
                  ),
                  CupertinoListTile(
                    leading: Icon(
                      CupertinoIcons.lightbulb,
                      color: CupertinoColors.activeBlue,
                    ),
                    title: Text('Consejos Médicos'),
                    subtitle: Text('Accede a información útil sobre salud'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Contacto',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Para soporte técnico o consultas generales, contáctanos a través de la aplicación o envía un correo a support@doctorappointmentapp.com',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '© 2023 Doctor Appointment App. Todos los derechos reservados.',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
