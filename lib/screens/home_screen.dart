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
  List<DoctorModel> _doctors = [];
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
    _doctorsStream = DatabaseService().getDoctors();
    _doctorsStream.listen((doctors) {
      setState(() {
        _doctors = doctors;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String userName = 'Usuario';
                    String userRole = 'Paciente';
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final userModel = UserModel.fromMap(
                        snapshot.data!.data() as Map<String, dynamic>,
                        snapshot.data!.id,
                      );
                      userName =
                          userModel.name ??
                          FirebaseAuth.instance.currentUser?.email ??
                          'Usuario';
                      userRole = userModel.role;
                    }
                    return Container(
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
                                  "¡Hola, $userName!",
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
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Action cards based on role
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String userRole = 'Paciente';
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final userModel = UserModel.fromMap(
                        snapshot.data!.data() as Map<String, dynamic>,
                        snapshot.data!.id,
                      );
                      userRole = userModel.role;
                    }
                    if (userRole == 'Paciente') {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onLongPress: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ver citas rápidas'),
                                ),
                              );
                              Navigator.pushNamed(context, '/appointments');
                            },
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/appointments');
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Mis Citas",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (userRole == 'Médico') {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onLongPress: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ver dashboard')),
                              );
                              Navigator.pushNamed(context, '/dashboard');
                            },
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/dashboard');
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bar_chart,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Ver Citas",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Consejos médicos rápidos'),
                          ),
                        );
                        Navigator.pushNamed(context, '/medical_tips');
                      },
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/medical_tips');
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.blue,
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Consejos Médicos",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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

                    return ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _doctors.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          final item = _doctors.removeAt(oldIndex);
                          _doctors.insert(
                            newIndex > oldIndex ? newIndex - 1 : newIndex,
                            item,
                          );
                        });
                      },
                      itemBuilder: (context, index) {
                        final doctor = _doctors[index];
                        return Card(
                          key: ValueKey(doctor.id),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(Icons.person, color: Colors.blue),
                            title: Text(doctor.name),
                            subtitle: Text(doctor.specialty),
                            trailing: Icon(
                              Icons.drag_handle,
                              size: 16,
                              color: Colors.grey,
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
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
