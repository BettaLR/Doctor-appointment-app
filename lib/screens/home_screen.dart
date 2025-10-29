import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../models/user_model.dart';
import '../models/doctor_model.dart';
import '../services/database_service.dart';
import 'new_appointment_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String? _userName;
  bool _isHoveringNewAppointment = false;
  bool _isHoveringMyAppointments = false;
  bool _isHoveringMedicalTips = false;
  int? _hoveredDoctorIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _loadUserName();
    _doctorsStream = DatabaseService().getDoctors();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final userModel = UserModel.fromMap(doc.data()!, doc.id);
        setState(() {
          _userName = userModel.name ?? user.email;
        });
      } else {
        setState(() {
          _userName = user.email;
        });
      }
    }
  }

  late final Stream<List<DoctorModel>> _doctorsStream;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message with user name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF93C5FD), Color(0xFF60A5FA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "¡Hola, ${_userName ?? 'Usuario'}!",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              "Bienvenido a tu app de citas médicas",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action cards
                Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) =>
                          setState(() => _isHoveringNewAppointment = true),
                      onExit: (_) =>
                          setState(() => _isHoveringNewAppointment = false),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/new_appointment');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isHoveringNewAppointment
                                ? Colors.blue[100]
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isHoveringNewAppointment
                                ? [
                                    const BoxShadow(
                                      color: Colors.blue,
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.add, color: Colors.blue, size: 28),
                              SizedBox(height: 8),
                              Text(
                                "Agendar una Cita",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) =>
                          setState(() => _isHoveringMyAppointments = true),
                      onExit: (_) =>
                          setState(() => _isHoveringMyAppointments = false),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/appointments');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isHoveringMyAppointments
                                ? Colors.blue[100]
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isHoveringMyAppointments
                                ? [
                                    const BoxShadow(
                                      color: Colors.blue,
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                                size: 28,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Mis Citas",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringMedicalTips = true),
                  onExit: (_) => setState(() => _isHoveringMedicalTips = false),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/medical_tips');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width:
                          MediaQuery.of(context).size.width *
                          0.4, // 40% of screen width
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isHoveringMedicalTips
                            ? Colors.blue[100]
                            : Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _isHoveringMedicalTips
                            ? [
                                const BoxShadow(
                                  color: Colors.blue,
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue, size: 28),
                          SizedBox(height: 8),
                          Text(
                            "Consejos Médicos",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Specialists list
              const Text(
                "Especialistas Disponibles",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<DoctorModel>>(
                stream: _doctorsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar doctores'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final doctors = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      final isHovered = _hoveredDoctorIndex == index;
                      return MouseRegion(
                        onEnter: (_) =>
                            setState(() => _hoveredDoctorIndex = index),
                        onExit: (_) =>
                            setState(() => _hoveredDoctorIndex = null),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isHovered
                                ? [
                                    const BoxShadow(
                                      color: Colors.blue,
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Card(
                            elevation: isHovered ? 2 : 1,
                            child: ListTile(
                              leading: Icon(
                                Icons.person,
                                color: isHovered
                                    ? Colors.blue[800]
                                    : Colors.blue,
                              ),
                              title: Text(doctor.name),
                              subtitle: Text(doctor.specialty),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: isHovered
                                    ? Colors.blue[800]
                                    : Colors.grey,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewAppointmentScreen(
                                      selectedDoctorId: doctor.id,
                                      selectedDoctorName: doctor.name,
                                      selectedSpecialty: doctor.specialty,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
