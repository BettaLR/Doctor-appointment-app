import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'messages_screen.dart';
import 'settings_screen.dart';
import 'appointments_screen.dart';
import 'graphics_page.dart';
import '../models/user_model.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  String _userRole = 'Paciente'; // Default role
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final userModel = UserModel.fromMap(doc.data()!, doc.id);
          if (mounted) {
            setState(() {
              _userRole = userModel.role;
              debugPrint(
                'DEBUG: Fetched role for user ${user.email}: $_userRole',
              );
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        debugPrint('Error fetching user role: $e');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  List<Widget> get _screens {
    final screens = <Widget>[
      const HomePage(),
      const AppointmentsScreen(),
      const MessagesScreen(),
    ];

    if (_userRole == 'Médico') {
      screens.add(const GraphicsPage());
    }

    screens.add(const SettingsScreen());
    return screens;
  }

  List<BottomNavigationBarItem> get _navItems {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Citas',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.message),
        label: 'Mensajes',
      ),
    ];

    if (_userRole == 'Médico') {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Gráficas',
        ),
      );
    }

    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Configuración',
      ),
    );
    return items;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF88D8B0), // Mint Green
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure labels are always visible
      ),
    );
  }
}
