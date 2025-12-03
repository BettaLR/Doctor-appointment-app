import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> messages = [
      {
        'name': 'Dr. Ana García',
        'message': 'Su cita ha sido confirmada para mañana.',
        'time': '10:30 AM',
        'avatar': 'AG',
        'color': '0xFF88D8B0', // Mint Green
      },
      {
        'name': 'Dr. Carlos Ruiz',
        'message': 'Por favor traiga sus radiografías.',
        'time': 'Ayer',
        'avatar': 'CR',
        'color': '0xFF4A90E2', // Blue
      },
      {
        'name': 'Soporte',
        'message': 'Bienvenido a la aplicación.',
        'time': '20 Nov',
        'avatar': 'S',
        'color': '0xFF9B9B9B', // Grey
      },
    ];

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mensajes'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            return Container(
              color: CupertinoColors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(int.parse(msg['color']!)),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              msg['avatar']!,
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                inherit: false,
                                fontFamily: '.SF Pro Text',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    msg['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: CupertinoColors.black,
                                      inherit: false,
                                      fontFamily: '.SF Pro Text',
                                    ),
                                  ),
                                  Text(
                                    msg['time']!,
                                    style: const TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontSize: 14,
                                      inherit: false,
                                      fontFamily: '.SF Pro Text',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg['message']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 14,
                                  inherit: false,
                                  fontFamily: '.SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          CupertinoIcons.chevron_right,
                          color: CupertinoColors.systemGrey4,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  if (index < messages.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 82.0),
                      child: Divider(
                        height: 1,
                        color: CupertinoColors.systemGrey5,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
