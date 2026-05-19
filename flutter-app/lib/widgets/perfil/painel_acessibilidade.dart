import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/acessibilidade_view_model.dart';

/// Configurações de voz, texto e interação para deficiência visual.
class PainelAcessibilidade extends StatelessWidget {
  const PainelAcessibilidade({
    super.key,
    this.modoCompacto = false,
  });

  /// No chat, painel menor; no perfil, todas as opções.
  final bool modoCompacto;

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AcessibilidadeViewModel>();

    return Semantics(
      container: true,
      label: 'Configurações de acessibilidade',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x141F2A3D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!modoCompacto) ...[
              Row(
                children: [
                  Icon(
                    Icons.accessibility_new_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Acessibilidade',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Voz, leitura em áudio e tamanho do texto em todo o app.',
                style: TextStyle(fontSize: 13, color: Color(0xFF9EA9C2), height: 1.4),
              ),
              const SizedBox(height: 16),
            ],
            if (kIsWeb) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x2663A7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  modoCompacto
                      ? 'Chrome: toque em "Testar voz" uma vez antes de usar o assistente.'
                      : 'No Chrome, toque em "Testar voz" uma vez por sessão. '
                          'Permita o microfone nas configurações do site.',
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ler respostas em voz alta'),
              subtitle: const Text(
                'O assistente fala cada resposta do chat',
                style: TextStyle(fontSize: 12, color: Color(0xFF9EA9C2)),
              ),
              value: a11y.leituraAutomatica,
              onChanged: a11y.alternarLeituraAutomatica,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Texto ampliado'),
              subtitle: const Text(
                'Aumenta o tamanho da letra em todas as telas',
                style: TextStyle(fontSize: 12, color: Color(0xFF9EA9C2)),
              ),
              value: a11y.fonteAmpliada,
              onChanged: a11y.alternarFonteAmpliada,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Anunciar tela em voz alta'),
              subtitle: const Text(
                'Ao mudar de aba, o app diz onde você está',
                style: TextStyle(fontSize: 12, color: Color(0xFF9EA9C2)),
              ),
              value: a11y.anunciarTelas,
              onChanged: a11y.alternarAnunciarTelas,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Botões grandes'),
              subtitle: const Text(
                'Facilita tocar nas ações principais',
                style: TextStyle(fontSize: 12, color: Color(0xFF9EA9C2)),
              ),
              value: a11y.botoesGrandes,
              onChanged: a11y.alternarBotoesGrandes,
            ),
            if (!modoCompacto)
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alto contraste'),
                subtitle: const Text(
                  'Bordas mais visíveis em botões e cartões',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9EA9C2)),
                ),
                value: a11y.altoContraste,
                onChanged: a11y.alternarAltoContraste,
              ),
            if (!modoCompacto) ...[
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enviar ao parar de falar'),
                subtitle: const Text(
                  'No chat, a mensagem de voz é enviada ao finalizar a gravação',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9EA9C2)),
                ),
                value: a11y.envioAutomaticoPorVoz,
                onChanged: a11y.alternarEnvioAutomaticoPorVoz,
              ),
              const SizedBox(height: 8),
              Text(
                'Velocidade da voz: ${a11y.rotuloVelocidadeFala}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: a11y.velocidadeFala,
                min: 0,
                max: 1,
                divisions: 2,
                label: a11y.rotuloVelocidadeFala,
                onChanged: a11y.definirVelocidadeFala,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => a11y.testarVoz(),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Testar voz'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: const Color(0xFF63A7FF),
                      side: const BorderSide(color: Color(0xFF63A7FF)),
                    ),
                  ),
                ),
                if (!modoCompacto && a11y.estaFalando) ...[
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => a11y.pararLeitura(),
                    tooltip: 'Parar leitura',
                    icon: const Icon(Icons.stop_rounded),
                  ),
                ],
              ],
            ),
            if (a11y.mensagemErroVoz != null) ...[
              const SizedBox(height: 10),
              Text(
                a11y.mensagemErroVoz!,
                style: const TextStyle(fontSize: 12, color: Colors.orangeAccent),
              ),
            ],
            if (modoCompacto) ...[
              const SizedBox(height: 10),
              Text(
                a11y.estaOuvindo
                    ? 'Ouvindo… toque no microfone de novo para enviar.'
                    : 'Use o microfone na barra do chat para falar com o assistente.',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9EA9C2),
                  height: 1.4,
                ),
              ),
              if (a11y.transcricaoParcial.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Você disse: ${a11y.transcricaoParcial}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF63A7FF),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
            if (!modoCompacto) ...[
              const SizedBox(height: 12),
              _LinhaStatus(
                icone: Icons.record_voice_over_outlined,
                texto: a11y.leituraDisponivel
                    ? 'Leitura em voz: disponível'
                    : 'Leitura em voz: indisponível',
              ),
              const SizedBox(height: 6),
              _LinhaStatus(
                icone: Icons.mic_outlined,
                texto: a11y.vozDisponivel
                    ? 'Entrada por voz: disponível'
                    : 'Entrada por voz: indisponível neste dispositivo',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinhaStatus extends StatelessWidget {
  const _LinhaStatus({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 18, color: const Color(0xFF9EA9C2)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9EA9C2)),
          ),
        ),
      ],
    );
  }
}
