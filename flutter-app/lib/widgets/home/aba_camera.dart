import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/textos_acessibilidade.dart';
import '../../viewmodels/acessibilidade_view_model.dart';
import '../acessibilidade/botao_grande.dart';

class AbaCamera extends StatelessWidget {
  const AbaCamera({
    super.key,
    required this.aoCapturarEEnviar,
  });

  final Future<void> Function() aoCapturarEEnviar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('camera'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Descrever o ambiente',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Aponte o celular para frente. O app tira uma foto, analisa '
          'e fala em voz alta o que encontrou. A resposta também aparece no assistente.',
          style: TextStyle(color: Color(0xFF9EA9C2), height: 1.45),
        ),
        const SizedBox(height: 24),
        Semantics(
          label: 'Área da câmera. Use o botão capturar abaixo.',
          child: Container(
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF141F33),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Icon(
              Icons.center_focus_strong_rounded,
              size: 88,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(height: 20),
        BotaoGrande(
          destaque: true,
          rotulo: 'Capturar e descrever',
          descricao: 'Tira foto agora e lê o ambiente em voz alta',
          icone: Icons.camera_alt_rounded,
          aoPressionar: () => aoCapturarEEnviar(),
        ),
        const SizedBox(height: 12),
        Semantics(
          button: true,
          label: 'Ouvir instrução da câmera',
          child: OutlinedButton.icon(
            onPressed: () => context
                .read<AcessibilidadeViewModel>()
                .anunciarTelaNaAcaoDoUsuario(
                  TextosAcessibilidade.anuncioAbaDescrever,
                ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('Ouvir instrução'),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.03, end: 0);
  }
}
