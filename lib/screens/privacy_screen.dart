import 'package:flutter/cupertino.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Política de Privacidad'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Política de Privacidad',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Última actualización: 23 de octubre de 2023',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '1. Información que recopilamos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Recopilamos información personal que usted nos proporciona directamente, como su nombre, correo electrónico, edad, lugar de nacimiento y condiciones médicas cuando crea una cuenta o actualiza su perfil.',
                style: TextStyle(
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '2. Cómo usamos su información',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Utilizamos su información para proporcionar nuestros servicios de citas médicas, gestionar su cuenta, mejorar nuestra aplicación y comunicarnos con usted sobre sus citas.',
                style: TextStyle(
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '3. Compartir información',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No vendemos, alquilamos ni compartimos su información personal con terceros, excepto cuando sea necesario para proporcionar nuestros servicios o cuando lo exija la ley.',
                style: TextStyle(
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '4. Seguridad de datos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Implementamos medidas de seguridad técnicas y organizativas para proteger su información personal contra acceso no autorizado, alteración, divulgación o destrucción.',
                style: TextStyle(
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '5. Sus derechos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Usted tiene derecho a acceder, rectificar, eliminar o limitar el procesamiento de su información personal. Puede ejercer estos derechos contactándonos a través de la aplicación.',
                style: TextStyle(
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '6. Cambios a esta política',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Podemos actualizar esta política de privacidad de vez en cuando. Le notificaremos sobre cambios significativos publicando la nueva política en esta aplicación.',
                style: TextStyle(
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Si tiene alguna pregunta sobre esta política de privacidad, por favor contáctenos.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: CupertinoColors.black,
                  inherit: false,
                  fontFamily: '.SF Pro Text',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
