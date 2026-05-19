import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mensagem_chat.dart';
import '../../models/papel_chat.dart';
import '../../viewmodels/acessibilidade_view_model.dart';
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
    if (widget.aguardandoResposta) return;

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

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AcessibilidadeViewModel>();
    final escala = TextScaler.linear(a11y.escalaFonte);
    final paddingInferior = MediaQuery.paddingOf(context).bottom;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: escala),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 8 + paddingInferior),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Assistente visual',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fale pelo microfone, envie foto ou digite. Respostas podem ser lidas em voz alta.',
            ),
            const SizedBox(height: 10),
            const PainelAcessibilidadeChat(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: widget.controladorRolagem,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: widget.mensagens.length +
                    (widget.aguardandoResposta ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (widget.aguardandoResposta &&
                      index == widget.mensagens.length) {
                    return Semantics(
                      liveRegion: true,
                      label: 'Assistente está pensando',
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Assistente está pensando...',
                                style: TextStyle(color: Color(0xFF9EA9C2)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final mensagem = widget.mensagens[index];
                  final isUsuario = mensagem.papel == PapelChat.usuario;
                  final rotulo = isUsuario
                      ? 'Você disse: ${mensagem.texto}'
                      : 'Assistente: ${mensagem.texto}';

                  return Semantics(
                    label: rotulo,
                    button: !isUsuario,
                    child: Align(
                      alignment: isUsuario
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 330),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUsuario
                              ? const Color(0x2663A7FF)
                              : const Color(0x141F2A3D),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (mensagem.bytesImagem != null) ...[
                              Semantics(
                                label: 'Imagem enviada por você',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    mensagem.bytesImagem!,
                                    height: 160,
                                    width: 260,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            Text(mensagem.texto),
                            if (!isUsuario) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () =>
                                    widget.aoLerMensagem(mensagem.texto),
                                icon: const Icon(Icons.volume_up_rounded, size: 20),
                                label: const Text('Ouvir esta resposta'),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                  foregroundColor: const Color(0xFF63A7FF),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: const Color(0x141F2A3D),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Semantics(
                      button: true,
                      label: a11y.estaOuvindo
                          ? 'Parar gravação e enviar mensagem de voz'
                          : 'Gravar mensagem de voz',
                      child: IconButton(
                        onPressed: widget.aguardandoResposta
                            ? null
                            : () => _alternarMicrofone(a11y),
                        iconSize: 28,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(52, 52),
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
                        iconSize: 26,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        icon: const Icon(Icons.image_outlined),
                        color: const Color(0xFF63A7FF),
                      ),
                    ),
                    Expanded(
                      child: Semantics(
                        textField: true,
                        label: 'Digite sua pergunta ao assistente visual',
                        child: TextField(
                          controller: widget.controlador,
                          focusNode: _focoEntrada,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _enviar(),
                          minLines: 1,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Ou digite aqui…',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 14,
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
                          minimumSize: const Size(52, 52),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 26),
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
