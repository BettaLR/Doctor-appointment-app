import 'package:flutter/cupertino.dart';

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
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Consejos Médicos'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: CupertinoListSection.insetGrouped(
            children: _tips.map((tip) {
              return CupertinoListTile(
                leading: const Icon(
                  CupertinoIcons.lightbulb_fill,
                  color: CupertinoColors.activeBlue,
                ),
                title: Text(
                  tip,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.black,
                    inherit: false,
                    fontFamily: '.SF Pro Text',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
