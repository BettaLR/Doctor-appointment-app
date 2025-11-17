import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _databaseService = DatabaseService();
  int _totalAppointments = 0;
  int _pendingAppointments = 0;
  int _totalPatients = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final total = await _databaseService.getTotalAppointmentsForDoctor(
        user.uid,
      );
      final pending = await _databaseService.getPendingAppointmentsForDoctor(
        user.uid,
      );
      final patients = await _databaseService.getTotalPatientsForDoctor(
        user.uid,
      );
      setState(() {
        _totalAppointments = total;
        _pendingAppointments = pending;
        _totalPatients = patients;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Médico')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Actividad',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildIndicatorCard(
                    title: 'Total de Citas',
                    value: _totalAppointments.toString(),
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                  ),
                  _buildIndicatorCard(
                    title: 'Citas Pendientes',
                    value: _pendingAppointments.toString(),
                    icon: Icons.schedule,
                    color: Colors.orange,
                  ),
                  _buildIndicatorCard(
                    title: 'Total de Pacientes',
                    value: _totalPatients.toString(),
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                  _buildIndicatorCard(
                    title: 'Citas Hoy',
                    value: '0', // Placeholder, can be implemented later
                    icon: Icons.today,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
