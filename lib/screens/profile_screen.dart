import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthplaceController = TextEditingController();
  final _conditionsController = TextEditingController();

  bool _isLoading = false;
  bool _notificationsEnabled = true;
  double _fontSize = 16.0;
  String _selectedRole = 'Paciente'; // Default role

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final userModel = UserModel.fromMap(doc.data()!, doc.id);
        _nameController.text = userModel.name ?? '';
        _ageController.text = userModel.age?.toString() ?? '';
        _birthplaceController.text = userModel.birthplace ?? '';
        _conditionsController.text = userModel.conditions ?? '';
        _selectedRole = userModel.role;
      }
    }
  }

  Future<void> _saveProfile() async {
    // Simple validation
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _birthplaceController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text(
            'Por favor, complete todos los campos obligatorios.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        name: _nameController.text,
        age: int.tryParse(_ageController.text),
        birthplace: _birthplaceController.text,
        conditions: _conditionsController.text,
        role: _selectedRole,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      // If role changed to doctor, ensure doctor exists in doctors collection
      if (_selectedRole == 'Médico') {
        await DatabaseService().ensureDoctorExists(user.uid);
      }

      // Reload user data to update UI
      await _loadUserData();

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Éxito'),
          content: const Text('Perfil actualizado'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Perfil'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CupertinoListSection(
                  header: Text('Información Personal'),
                  children: [],
                ),
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Nombre',
                  padding: const EdgeInsets.all(12.0),
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: _ageController,
                  placeholder: 'Edad',
                  keyboardType: TextInputType.number,
                  padding: const EdgeInsets.all(12.0),
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: _birthplaceController,
                  placeholder: 'Lugar de nacimiento',
                  padding: const EdgeInsets.all(12.0),
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: _conditionsController,
                  placeholder: 'Condiciones médicas',
                  padding: const EdgeInsets.all(12.0),
                ),
                const SizedBox(height: 20),
                CupertinoListSection(
                  header: Text('Configuraciones'),
                  children: [],
                ),
                CupertinoListTile(
                  title: const Text('Notificaciones'),
                  trailing: CupertinoSwitch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Rol'),
                  subtitle: Text(_selectedRole),
                  trailing: const Icon(CupertinoIcons.chevron_right),
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                        title: const Text('Seleccionar Rol'),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () {
                              setState(() {
                                _selectedRole = 'Paciente';
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Paciente'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              setState(() {
                                _selectedRole = 'Médico';
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Médico'),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () => Navigator.pop(context),
                          isDestructiveAction: true,
                          child: const Text('Cancelar'),
                        ),
                      ),
                    );
                  },
                ),
                CupertinoListTile(
                  title: const Text('Tamaño de fuente'),
                  trailing: CupertinoSlider(
                    value: _fontSize,
                    min: 12.0,
                    max: 24.0,
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text('Guardar'),
                ),
                const SizedBox(height: 10),
                CupertinoButton(
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                        title: const Text('Opciones'),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Editar Foto'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cambiar Contraseña'),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () => Navigator.pop(context),
                          isDestructiveAction: true,
                          child: const Text('Cancelar'),
                        ),
                      ),
                    );
                  },
                  child: const Text('Más Opciones'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
