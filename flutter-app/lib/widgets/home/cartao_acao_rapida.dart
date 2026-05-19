import 'package:flutter/material.dart';

import '../../models/acao_rapida.dart';

class CartaoAcaoRapida extends StatelessWidget {
  const CartaoAcaoRapida({super.key, required this.acao});

  final AcaoRapida acao;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${acao.titulo}. ${acao.subtitulo}',
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0x141F2A3D),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x1A63A7FF),
              border: Border.all(color: const Color(0x3363A7FF)),
            ),
            child: Icon(acao.icone, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acao.titulo,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  acao.subtitulo,
                  style: const TextStyle(color: Color(0xFF9EA9C2)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9EA9C2)),
        ],
      ),
      ),
    );
  }
}
