import 'package:flutter/material.dart';

import 'linha_chip.dart';

class PainelStatus extends StatelessWidget {
  const PainelStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0x141F2A3D),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinhaChip(rotulo: 'Câmera', valor: 'pronta'),
          SizedBox(height: 10),
          LinhaChip(rotulo: 'IA', valor: 'online'),
          SizedBox(height: 10),
          LinhaChip(rotulo: 'Áudio', valor: 'ativo'),
        ],
      ),
    );
  }
}
