import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mensagem_chat.dart';
import '../../viewmodels/acessibilidade_view_model.dart';
import 'chat/bolha_mensagem_chat.dart';
import 'chat/cabecalho_chat.dart';
import 'chat/indicador_pensando.dart';
import 'painel_acessibilidade_chat.dart';

class AbaChat extends StatefulWidget {
  const AbaChat({
    super.key,
    required this.mensagens,
    required this.controlador,
    required this.controladorRolagem,
    required this.aguardandoResposta,
    required this.aoEnviar,
    required this.aoEnviarImagem,
    required this.aoEnviarTextoVoz,
    required this.aoLerMensagem,
    required this.aoNovaConversa,
    this.abaAtiva = false,
  });

  final List<MensagemChat> mensagens;
  final TextEditingController controlador;
  final ScrollController controladorRolagem;
  final bool aguardandoResposta;
  final VoidCallback aoEnviar;
  final VoidCallback aoEnviarImagem;
  final void Function(String texto) aoEnviarTextoVoz;
  final void Function(String texto) aoLerMensagem;
  final VoidCallback aoNovaConversa;
  final bool abaAtiva;

  @override
  State<AbaChat> createState() => AbaChatState();
}

class AbaChatState extends State<AbaChat> {
  final _focoEntrada = FocusNode();

  @override
  void didUpdateWidget(covariant AbaChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.abaAtiva && !oldWidget.abaAtiva) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !widget.aguardandoResposta) {
          _focoEntrada.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _focoEntrada.dispose();
    super.dispose();
  }

  void _enviar() {
    if (widget.aguardandoResposta) return;
    if (widget.controlador.text.trim().isEmpty) return;
    widget.aoEnviar();
  }

  Future<void> _alternarMicrofone(AcessibilidadeViewModel a11y) async {
    if (widget.aguardandoResposta && !a11y.estaOuvindo) return;

    final erro = await a11y.alternarGravacaoVoz(
      aoEnviarTexto: (texto) {
        widget.controlador.text = texto;
        widget.aoEnviarTextoVoz(texto);
      },
      aoParcial: (parcial) {
        widget.controlador.text = parcial;
      },
    );

    if (!mounted || erro == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(erro)),
    );
  }

  void _abrirAcessibilidade() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121A2B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Voz e acessibilidade',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: const PainelAcessibilidadeChat(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AcessibilidadeViewModel>();
    final paddingInferior = MediaQuery.paddingOf(context).bottom;

    final totalMensagens =
        widget.mensagens.length + (widget.aguardandoResposta ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CabecalhoChat(
          aoNovaConversa: widget.aoNovaConversa,
          aoAbrirAcessibilidade: _abrirAcessibilidade,
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.controladorRolagem,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            itemCount: totalMensagens,
            itemBuilder: (context, index) {
              if (widget.aguardandoResposta &&
                  index == widget.mensagens.length) {
                return const IndicadorPensando();
              }
              final mensagem = widget.mensagens[index];
              return BolhaMensagemChat(
                mensagem: mensagem,
                aoLerResposta: () => widget.aoLerMensagem(mensagem.texto),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 8 + paddingInferior),
          child: Material(
            color: const Color(0xFF141C2E),
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Semantics(
                    button: true,
                    label: a11y.estaOuvindo
                        ? 'Parar gravação e enviar mensagem de voz'
                        : 'Gravar mensagem de voz',
                    child: IconButton(
                      onPressed: (widget.aguardandoResposta &&
                              !a11y.estaOuvindo)
                          ? null
                          : () => _alternarMicrofone(a11y),
                      iconSize: 26,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        backgroundColor: a11y.estaOuvindo
                            ? const Color(0xFFE53935)
                            : const Color(0xFF2A3550),
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(
                        a11y.estaOuvindo
                            ? Icons.stop_rounded
                            : Icons.mic_rounded,
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Enviar foto para descrição',
                    child: IconButton(
                      onPressed: widget.aguardandoResposta
                          ? null
                          : widget.aoEnviarImagem,
                      iconSize: 24,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44),
                      ),
                      icon: const Icon(Icons.image_outlined),
                      color: const Color(0xFF9EA9C2),
                    ),
                  ),
                  Expanded(
                    child: Semantics(
                      textField: true,
                      label: 'Digite sua pergunta ao assistente',
                      child: TextField(
                        controller: widget.controlador,
                        focusNode: _focoEntrada,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _enviar(),
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Pergunte algo…',
                          hintStyle: TextStyle(color: Color(0xFF6B7589)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                        ),
                        enabled: !widget.aguardandoResposta,
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Enviar mensagem',
                    child: IconButton.filled(
                      onPressed: widget.aguardandoResposta ? null : _enviar,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        backgroundColor: const Color(0xFF2F7DE1),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
