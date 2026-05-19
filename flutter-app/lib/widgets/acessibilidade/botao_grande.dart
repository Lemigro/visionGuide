import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/acessibilidade_view_model.dart';

/// Botão alto, com área de toque ampla e rótulo para leitor de tela.
class BotaoGrande extends StatelessWidget {
  const BotaoGrande({
    super.key,
    required this.rotulo,
    required this.descricao,
    required this.icone,
    required this.aoPressionar,
    this.destaque = false,
  });

  final String rotulo;
  final String descricao;
  final IconData icone;
  final VoidCallback aoPressionar;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AcessibilidadeViewModel>();
    final alturaMinima = a11y.botoesGrandes ? 72.0 : 60.0;

    return Semantics(
      button: true,
      label: '$rotulo. $descricao',
      child: FilledButton(
        onPressed: aoPressionar,
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(alturaMinima),
          backgroundColor: destaque
              ? const Color(0xFF2F7DE1)
              : const Color(0xFF1A2A45),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Icon(icone, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rotulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: TextStyle(
                      fontSize: a11y.fonteAmpliada ? 15 : 13,
                      color: Colors.white.withOpacity(0.82),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
