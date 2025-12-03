import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import 'profile_screen.dart';
import 'privacy_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Configuración'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('General'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.person),
                  title: const Text('Perfil'),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey3,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.lock),
                  title: const Text('Privacidad'),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey3,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const PrivacyScreen(),
                      ),
                    );
                  },
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.info),
                  title: const Text('Sobre Nosotros'),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey3,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('Cuenta'),
              children: [
                CupertinoListTile(
                  leading: const Icon(
                    CupertinoIcons.square_arrow_left,
                    color: CupertinoColors.destructiveRed,
                  ),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text(
                          '¿Estás seguro de que quieres cerrar sesión?',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<AuthBloc>().add(
                                AuthLogoutRequested(),
                              );
                            },
                            child: const Text('Cerrar Sesión'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
