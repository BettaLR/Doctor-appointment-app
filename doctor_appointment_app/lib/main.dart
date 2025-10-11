import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  // 🔹 Asegura la inicialización antes de correr la app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login de prueba',
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Demo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de correo electrónico
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su correo electrónico';
                  }
                  // 🔹 Validación de formato de correo
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Correo no válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de contraseña
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingrese su contraseña";
                  }
                  // 🔹 Validación de longitud mínima
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Botón de inicio de sesión
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      UserCredential userCredential = await _auth
                          .signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Bienvenido ${userCredential.user!.email}",
                          ),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      String message = "";
                      if (e.code == 'user-not-found') {
                        message = "Usuario no encontrado";
                      } else if (e.code == 'wrong-password') {
                        message = "Contraseña incorrecta";
                      } else {
                        message = "Error: ${e.message}";
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    }
                  }
                },
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 16),
              // Botón de cerrar sesión
              ElevatedButton(
                onPressed: () async {
                  await _auth.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sesión cerrada")),
                  );
                },
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
