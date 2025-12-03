import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add intl for date formatting
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart'; // Import AppointmentModel
import 'new_appointment_screen.dart';
import 'graphics_page.dart'; // Import GraphicsPage
import 'messages_screen.dart'; // Import MessagesScreen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modern Header
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String userName = 'Usuario';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final userModel = UserModel.fromMap(
                            snapshot.data!.data() as Map<String, dynamic>,
                            snapshot.data!.id,
                          );
                          userName =
                              userModel.name ??
                              FirebaseAuth.instance.currentUser?.email ??
                              'Usuario';
                        }
                        return Container(
                          padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF88D8B0), // Mint Green
                                Color(0xFFA8E6CF), // Lighter Mint
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hola,',
                                        style: TextStyle(
                                          color: CupertinoColors.white
                                              .withOpacity(0.9),
                                          fontSize: 18,
                                          inherit: false,
                                          fontFamily: '.SF Pro Text',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          color: CupertinoColors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          inherit: false,
                                          fontFamily: '.SF Pro Display',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/settings',
                                            ); // Navigate to settings/profile
                                          },
                                          child: const Icon(
                                            CupertinoIcons.person_circle,
                                            color: CupertinoColors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          CupertinoIcons.bell,
                                          color: CupertinoColors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.search,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Text(
                                          'Buscar doctor o especialidad...',
                                          style: TextStyle(
                                            color: CupertinoColors.systemGrey,
                                            inherit: false,
                                            fontFamily: '.SF Pro Text',
                                            fontSize: 15,
                                          ),
                                        ),
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
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Próxima Cita Section
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('appointments')
                                .where(
                                  'userId',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser?.uid,
                                )
                                .where('status', isEqualTo: 'scheduled')
                                .orderBy('startTime')
                                .limit(1)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final appointment = AppointmentModel.fromMap(
                                snapshot.data!.docs.first.data()
                                    as Map<String, dynamic>,
                                snapshot.data!.docs.first.id,
                              );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Próxima Cita',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.black,
                                      inherit: false,
                                      fontFamily: '.SF Pro Display',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF88D8B0,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF88D8B0),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF88D8B0),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            CupertinoIcons.calendar,
                                            color: CupertinoColors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                appointment.doctorName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: CupertinoColors.black,
                                                  inherit: false,
                                                  fontFamily: '.SF Pro Text',
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat(
                                                  'EEE, d MMM • h:mm a',
                                                ).format(
                                                  appointment.startTime
                                                      .toLocal(),
                                                ),
                                                style: const TextStyle(
                                                  color: CupertinoColors
                                                      .systemGrey,
                                                  fontSize: 14,
                                                  inherit: false,
                                                  fontFamily: '.SF Pro Text',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              );
                            },
                          ),
                          const Text(
                            'Acciones Rápidas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.black,
                              inherit: false,
                              fontFamily: '.SF Pro Display',
                            ),
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              bool isDoctor = false;
                              if (snapshot.hasData && snapshot.data!.exists) {
                                final data =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;
                                isDoctor = data['role'] == 'Médico';
                              }
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildActionCard(
                                    context,
                                    icon: CupertinoIcons.calendar_badge_plus,
                                    label: 'Agendar',
                                    color: const Color(0xFF88D8B0),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              const NewAppointmentScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildActionCard(
                                    context,
                                    icon: CupertinoIcons.doc_text,
                                    label: 'Recetas',
                                    color: const Color(0xFFA8E6CF),
                                    onTap: () {},
                                  ),
                                  _buildActionCard(
                                    context,
                                    icon: CupertinoIcons.chart_bar_alt_fill,
                                    label: 'Estadísticas',
                                    color: isDoctor
                                        ? const Color(0xFFDCEDC8)
                                        : CupertinoColors.systemGrey4,
                                    onTap: () {
                                      if (isDoctor) {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                const GraphicsPage(),
                                          ),
                                        );
                                      } else {
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (context) =>
                                              CupertinoAlertDialog(
                                                title: const Text(
                                                  'Acceso Restringido',
                                                ),
                                                content: const Text(
                                                  'Solo los médicos pueden acceder a las estadísticas.',
                                                ),
                                                actions: [
                                                  CupertinoDialogAction(
                                                    child: const Text('OK'),
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                  ),
                                                ],
                                              ),
                                        );
                                      }
                                    },
                                  ),
                                  _buildActionCard(
                                    context,
                                    icon: CupertinoIcons.chat_bubble_2,
                                    label: 'Chat',
                                    color: const Color(0xFF88D8B0),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              const MessagesScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Doctores Populares',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.black,
                                  inherit: false,
                                  fontFamily: '.SF Pro Display',
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: const Text(
                                  'Ver todos',
                                  style: TextStyle(
                                    color: Color(0xFF88D8B0), // Mint Green
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDoctorCard(
                            context,
                            'Dr. Juan Pérez',
                            'Cardiología',
                            '4.8',
                            'assets/doctor1.png',
                          ),
                          _buildDoctorCard(
                            context,
                            'Dra. María García',
                            'Dermatología',
                            '4.9',
                            'assets/doctor2.png',
                          ),
                          _buildDoctorCard(
                            context,
                            'Dr. Carlos López',
                            'Neurología',
                            '4.7',
                            'assets/doctor3.png',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // Using color passed as argument
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.black,
              inherit: false,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(
    BuildContext context,
    String name,
    String specialty,
    String rating,
    String imagePath,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(
                0xFF88D8B0,
              ).withOpacity(0.2), // Mint Green opacity
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              color: Color(0xFF88D8B0), // Mint Green
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                    inherit: false,
                    fontFamily: '.SF Pro Display',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                    inherit: false,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4), // Light yellow for rating
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.star_fill,
                  color: Color(0xFFFFB300), // Amber
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB300),
                    inherit: false,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
