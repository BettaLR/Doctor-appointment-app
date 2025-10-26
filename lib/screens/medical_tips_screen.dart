import 'package:flutter/material.dart';

class MedicalTipsScreen extends StatelessWidget {
  const MedicalTipsScreen({super.key});

  final List<String> _tips = const [
    'Mantén una dieta equilibrada rica en frutas y verduras.',
    'Ejercítate regularmente al menos 30 minutos al día.',
    'Duerme entre 7-9 horas por noche.',
    'Bebe al menos 8 vasos de agua al día.',
    'Lávate las manos frecuentemente para prevenir infecciones.',
    'Programa revisiones médicas anuales.',
    'Evita el tabaco y limita el consumo de alcohol.',
    'Gestiona el estrés con técnicas de relajación.',
    'Mantén un peso saludable.',
    'Vacúnate según el calendario recomendado.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consejos Médicos'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: ListView.builder(
        itemCount: _tips.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.lightbulb, color: Colors.blue),
            title: Text(_tips[index]),
          );
        },
      ),
    );
  }
}
