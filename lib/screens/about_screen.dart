import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Nosotros'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const Icon(
              Icons.medical_services,
              size: 80,
              color: Color(0xFF3B82F6),
            ),
            const SizedBox(height: 24),
            const Text(
              'Doctor Appointment App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Versión 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              'Nuestra Misión',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Facilitar el acceso a servicios médicos de calidad, conectando pacientes con profesionales de la salud de manera eficiente y segura.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text(
              'Características Principales',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.calendar_today, color: Color(0xFF3B82F6)),
                  title: Text('Agendamiento de Citas'),
                  subtitle: Text('Programa citas con especialistas fácilmente'),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Color(0xFF3B82F6)),
                  title: Text('Perfiles Personales'),
                  subtitle: Text(
                    'Gestiona tu información médica de forma segura',
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.notifications, color: Color(0xFF3B82F6)),
                  title: Text('Recordatorios'),
                  subtitle: Text('Recibe notificaciones de tus citas'),
                ),
                ListTile(
                  leading: Icon(Icons.lightbulb, color: Color(0xFF3B82F6)),
                  title: Text('Consejos Médicos'),
                  subtitle: Text('Accede a información útil sobre salud'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Contacto',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Para soporte técnico o consultas generales, contáctanos a través de la aplicación o envía un correo a support@doctorappointmentapp.com',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text(
              '© 2023 Doctor Appointment App. Todos los derechos reservados.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
