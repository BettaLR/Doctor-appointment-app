import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/new_appointment_screen.dart';
import 'screens/edit_appointment_screen.dart';
import 'screens/medical_tips_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/about_screen.dart';
import 'models/appointment_model.dart';
import 'services/database_service.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/auth_state.dart';
import 'blocs/auth_event.dart';

void main() async {
  // Asegura la inicialización de Firebase antes de correr la app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize doctors in Firestore
  final databaseService = DatabaseService();
  await databaseService.initializeDoctors();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(AuthCheckRequested()),
      child: MaterialApp(
        title: 'Doctor Appointment App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Fuente moderna y estética
          fontFamily: 'Poppins',

          // Esquema de color basado en tu azul principal
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B82F6),
            brightness: Brightness.light,
          ),

          // Activamos Material 3 para botones y elevaciones suaves
          useMaterial3: true,

          // Estilos generales de AppBar y botones
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              elevation: 2,
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const NavigationScreen(),
          '/register': (context) => const RegisterScreen(),
          '/appointments': (context) => const AppointmentsScreen(),
          '/new_appointment': (context) => const NewAppointmentScreen(),
          '/edit_appointment': (context) => EditAppointmentScreen(
            appointment:
                ModalRoute.of(context)!.settings.arguments as AppointmentModel,
          ),
          '/medical_tips': (context) => const MedicalTipsScreen(),
          '/privacy': (context) => const PrivacyScreen(),
          '/about': (context) => const AboutScreen(),
        },
      ),
    );
  }
}
