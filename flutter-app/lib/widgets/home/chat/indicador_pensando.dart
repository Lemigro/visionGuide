import 'package:flutter/material.dart';

import 'bolha_mensagem_chat.dart';

class IndicadorPensando extends StatelessWidget {
  const IndicadorPensando({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Semantics(
        liveRegion: true,
        label: 'Assistente está pensando',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF2F7DE1),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  gradient: BolhaMensagemChat.gradienteAssistente,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2F7DE1),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Pensando…',
                      style: TextStyle(
                        color: Color(0xFF5C6578),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
