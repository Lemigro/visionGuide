import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/acao_rapida.dart';
import 'cartao_acao_rapida.dart';
import 'cartao_hero.dart';
import 'painel_status.dart';
import 'titulo_secao.dart';

class AbaInicio extends StatefulWidget {
  const AbaInicio({
    super.key,
    required this.atalhos,
    required this.aoAbrirCamera,
    required this.aoAbrirChat,
    required this.aoAbrirGaleria,
  });

  final List<AcaoRapida> atalhos;
  final VoidCallback aoAbrirCamera;
  final VoidCallback aoAbrirChat;
  final VoidCallback aoAbrirGaleria;

  @override
  State<AbaInicio> createState() => AbaInicioState();
}

class AbaInicioState extends State<AbaInicio> {
  static const dicaPadrao =
      'Dica: use "Conversar com IA" para perguntas rápidas, '
      '"Galeria" para mídias recentes e "Abrir Câmera Assistiva" '
      'para descrição de ambiente.';

  String infoPainel = '';

  void definirInfo(String texto) {
    setState(() => infoPainel = texto);
  }

  void aoTocarAtalho(AcaoRapida acao) {
    final titulo = acao.titulo.toLowerCase();
    if (titulo.contains('obstáculo') || titulo.contains('obstaculo')) {
      widget.aoAbrirChat();
    } else {
      widget.aoAbrirCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const CartaoHero(),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: widget.aoAbrirCamera,
          icon: const Icon(Icons.center_focus_strong_rounded),
          label: const Text('Abrir Câmera Assistiva'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: widget.aoAbrirChat,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2F7DE1),
          ),
          icon: const Icon(Icons.chat_bubble_rounded),
          label: const Text('Conversar com IA'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: widget.aoAbrirGaleria,
          style: FilledButton.styleFrom(
            foregroundColor: const Color(0xFF171923),
            backgroundColor: const Color(0xFFE9EDF8),
          ),
          icon: const Icon(Icons.photo_library_rounded),
          label: const Text('Galeria de Fotos e Vídeos'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => definirInfo(
            'O VisionGuide ajuda pessoas com deficiência visual com leitura '
            'de textos, descrição de ambientes e alerta de obstáculos em tempo real.',
          ),
          child: const Text('Sobre o Projeto'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => definirInfo(
            'Contato da equipe: visionguide.contato@gmail.com',
          ),
          child: const Text('Contato'),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0x141F2A3D),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            infoPainel.isEmpty ? dicaPadrao : infoPainel,
            style: const TextStyle(
              color: Color(0xFFBCC4DA),
              height: 1.45,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 18),
        TituloSecao(
          titulo: 'Atalhos rápidos',
          subtitulo: 'Ações mais usadas no app',
          aoVerTudo: widget.aoAbrirGaleria,
        ),
        const SizedBox(height: 10),
        ...widget.atalhos.map(
          (acao) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => aoTocarAtalho(acao),
                child: CartaoAcaoRapida(acao: acao),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const TituloSecao(
          titulo: 'Status da sessão',
          subtitulo: 'Resumo visual do protótipo',
        ),
        const SizedBox(height: 10),
        const PainelStatus(),
      ],
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.03, end: 0);
  }
}
