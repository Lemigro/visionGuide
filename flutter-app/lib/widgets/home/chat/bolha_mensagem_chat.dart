import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/mensagem_chat.dart';
import '../../../models/papel_chat.dart';

class BolhaMensagemChat extends StatelessWidget {
  const BolhaMensagemChat({
    super.key,
    required this.mensagem,
    required this.aoLerResposta,
  });

  final MensagemChat mensagem;
  final VoidCallback aoLerResposta;

  static const gradienteAssistente = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4F6F9), Color(0xFFE6F2FA), Color(0xFFE8F5EE)],
  );

  bool get _isUsuario => mensagem.papel == PapelChat.usuario;

  @override
  Widget build(BuildContext context) {
    final rotulo = _isUsuario
        ? 'Você disse: ${mensagem.texto}'
        : 'Assistente: ${mensagem.texto}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Semantics(
        label: rotulo,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AvatarMensagem(usuario: _isUsuario),
            const SizedBox(width: 10),
            Expanded(
              child: _isUsuario
                  ? _TextoUsuario(texto: mensagem.texto, imagem: mensagem.bytesImagem)
                  : _BolhaAssistente(
                      texto: mensagem.texto,
                      imagem: mensagem.bytesImagem,
                      aoLer: aoLerResposta,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarMensagem extends StatelessWidget {
  const _AvatarMensagem({required this.usuario});

  final bool usuario;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor:
          usuario ? const Color(0xFF3D4F6E) : const Color(0xFF2F7DE1),
      child: Icon(
        usuario ? Icons.person_rounded : Icons.smart_toy_rounded,
        size: 22,
        color: Colors.white,
      ),
    );
  }
}

class _TextoUsuario extends StatelessWidget {
  const _TextoUsuario({required this.texto, this.imagem});

  final String texto;
  final Uint8List? imagem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagem != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(imagem!, height: 140, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BolhaAssistente extends StatelessWidget {
  const _BolhaAssistente({
    required this.texto,
    this.imagem,
    required this.aoLer,
  });

  final String texto;
  final Uint8List? imagem;
  final VoidCallback aoLer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
      decoration: BoxDecoration(
        gradient: BolhaMensagemChat.gradienteAssistente,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagem != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(imagem!, height: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            texto,
            style: const TextStyle(
              color: Color(0xFF1A1F2E),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: _AcoesResposta(
              texto: texto,
              aoLer: aoLer,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcoesResposta extends StatelessWidget {
  const _AcoesResposta({required this.texto, required this.aoLer});

  final String texto;
  final VoidCallback aoLer;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AcaoIcone(
          icone: Icons.content_copy_rounded,
          rotulo: 'Copiar resposta',
          onTap: () {
            Clipboard.setData(ClipboardData(text: texto));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resposta copiada'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        _AcaoIcone(
          icone: Icons.volume_up_rounded,
          rotulo: 'Ouvir resposta em voz alta',
          onTap: aoLer,
        ),
        _AcaoIcone(
          icone: Icons.thumb_up_outlined,
          rotulo: 'Resposta útil',
          onTap: () => _feedback(context, positivo: true),
        ),
        _AcaoIcone(
          icone: Icons.thumb_down_outlined,
          rotulo: 'Resposta não útil',
          onTap: () => _feedback(context, positivo: false),
        ),
      ],
    );
  }

  void _feedback(BuildContext context, {required bool positivo}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          positivo ? 'Obrigado pelo feedback positivo' : 'Obrigado, vamos melhorar',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _AcaoIcone extends StatelessWidget {
  const _AcaoIcone({
    required this.icone,
    required this.rotulo,
    required this.onTap,
  });

  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: rotulo,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icone, size: 20, color: const Color(0xFF8A94A8)),
        style: IconButton.styleFrom(
          minimumSize: const Size(40, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
