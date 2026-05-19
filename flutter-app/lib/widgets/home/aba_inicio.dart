import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../models/acao_rapida.dart';
import '../../models/destino_acao_rapida.dart';
import '../../viewmodels/acessibilidade_view_model.dart';
import '../acessibilidade/botao_grande.dart';
import 'cartao_acao_rapida.dart';
import 'titulo_secao.dart';

class AbaInicio extends StatelessWidget {
  const AbaInicio({
    super.key,
    required this.atalhos,
    required this.aoAbrirCamera,
    required this.aoAbrirChat,
    required this.aoAbrirAjustes,
  });

  final List<AcaoRapida> atalhos;
  final VoidCallback aoAbrirCamera;
  final VoidCallback aoAbrirChat;
  final VoidCallback aoAbrirAjustes;

  void _aoTocarAtalho(AcaoRapida acao) {
    switch (acao.destino) {
      case DestinoAcaoRapida.camera:
        aoAbrirCamera();
      case DestinoAcaoRapida.assistente:
        aoAbrirChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AcessibilidadeViewModel>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Semantics(
          header: true,
          child: Text(
            'O que você precisa agora?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Vision Guide descreve o mundo ao seu redor. '
          'Escolha uma ação abaixo — tudo pode ser usado por voz.',
          style: TextStyle(color: Color(0xFF9EA9C2), height: 1.45),
        ),
        const SizedBox(height: 20),
        BotaoGrande(
          destaque: true,
          rotulo: 'Descrever o ambiente',
          descricao: 'A câmera analisa e fala o que está na frente',
          icone: Icons.center_focus_strong_rounded,
          aoPressionar: aoAbrirCamera,
        ),
        const SizedBox(height: 12),
        BotaoGrande(
          rotulo: 'Falar com o assistente',
          descricao: 'Pergunte por voz ou envie uma foto',
          icone: Icons.mic_rounded,
          aoPressionar: aoAbrirChat,
        ),
        const SizedBox(height: 12),
        Semantics(
          button: true,
          label: 'Ouvir orientação de uso do aplicativo',
          child: OutlinedButton.icon(
            onPressed: () => a11y.anunciarOrientacaoInicial(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('Ouvir como usar o app'),
          ),
        ),
        const SizedBox(height: 24),
        const TituloSecao(
          titulo: 'Atalhos',
          subtitulo: 'Mesmas funções, toque direto',
        ),
        const SizedBox(height: 10),
        ...atalhos.map(
          (acao) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _aoTocarAtalho(acao),
                child: CartaoAcaoRapida(acao: acao),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: 'Abrir ajustes de acessibilidade, voz e texto',
          child: TextButton.icon(
            onPressed: aoAbrirAjustes,
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Ajustes de acessibilidade'),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.03, end: 0);
  }
}
