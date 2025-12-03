import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _selectedRole = 'Paciente'; // Default role

  void _register() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorDialog('Por favor complete todos los campos');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      _showErrorDialog('Correo electrónico no válido');
      return;
    }
    if (passwordController.text.length < 6) {
      _showErrorDialog('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        emailController.text.trim(),
        passwordController.text.trim(),
      ),
    );
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
      backgroundColor: CupertinoColors.white,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            // Create user document in Firestore
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final userModel = UserModel(
                id: user.uid,
                email: user.email!,
                role: _selectedRole,
              );
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .set(userModel.toMap());

              // If user is a doctor, add to doctors collection
              if (_selectedRole == 'Médico') {
                await DatabaseService().ensureDoctorExists(user.uid);
              }
            }

            // ignore: use_build_context_synchronously
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Éxito'),
                content: const Text('Cuenta creada exitosamente'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                ],
              ),
            );
          } else if (state is AuthError) {
            _showErrorDialog(state.message);
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with Gradient and Logo
              Container(
                height: 250,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.person_add_solid,
                          size: 60,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Únete a MediApp',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                          letterSpacing: 1.2,
                          inherit: false,
                          fontFamily: '.SF Pro Display',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Register Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Crea tu cuenta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                        inherit: false,
                        fontFamily: '.SF Pro Display',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    CupertinoTextField(
                      controller: emailController,
                      placeholder: 'Correo Electrónico',
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(
                          CupertinoIcons.mail,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CupertinoTextField(
                      controller: passwordController,
                      placeholder: 'Contraseña',
                      obscureText: true,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(
                          CupertinoIcons.lock,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Role Selection
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<String>(
                        groupValue: _selectedRole,
                        children: const {
                          'Paciente': Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Paciente'),
                          ),
                          'Médico': Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Médico'),
                          ),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }
                        return CupertinoButton.filled(
                          onPressed: _register,
                          borderRadius: BorderRadius.circular(12),
                          child: const Text(
                            'REGISTRARSE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes cuenta?',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            inherit: false,
                            fontFamily: '.SF Pro Text',
                          ),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.only(left: 4),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Inicia Sesión',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ),
                      ],
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
}
