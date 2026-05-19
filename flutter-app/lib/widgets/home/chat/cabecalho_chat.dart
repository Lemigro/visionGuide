import 'package:flutter/material.dart';

class CabecalhoChat extends StatelessWidget {
  const CabecalhoChat({
    super.key,
    required this.aoNovaConversa,
    required this.aoAbrirAcessibilidade,
  });

  final VoidCallback aoNovaConversa;
  final VoidCallback aoAbrirAcessibilidade;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Configurações de voz e acessibilidade do chat',
            child: IconButton(
              onPressed: aoAbrirAcessibilidade,
              icon: const Icon(Icons.tune_rounded, color: Color(0xFF9EA9C2)),
            ),
          ),
          const Expanded(
            child: Text(
              'Assistente IA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Iniciar nova conversa',
            child: IconButton(
              onPressed: aoNovaConversa,
              icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF9EA9C2)),
            ),
          ),
        ],
      ),
    );
  }
}
