import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/acessibilidade_view_model.dart';

class PainelAcessibilidadeChat extends StatelessWidget {
  const PainelAcessibilidadeChat({super.key});

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AcessibilidadeViewModel>();

    return Semantics(
      container: true,
      label: 'Opções de acessibilidade do chat',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x141F2A3D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (kIsWeb) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x2663A7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Chrome: toque em "Testar voz" uma vez (exigência do navegador). '
                  'Depois permita o microfone para falar com o assistente.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ler respostas em voz alta'),
              subtitle: Text(
                a11y.executandoNaWeb
                    ? 'Após "Testar voz", cada resposta será falada'
                    : 'O assistente fala automaticamente cada resposta',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9EA9C2)),
              ),
              value: a11y.leituraAutomatica,
              onChanged: a11y.alternarLeituraAutomatica,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Texto ampliado'),
              value: a11y.fonteAmpliada,
              onChanged: a11y.alternarFonteAmpliada,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => a11y.testarVoz(),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Testar voz'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: const Color(0xFF63A7FF),
                side: const BorderSide(color: Color(0xFF63A7FF)),
              ),
            ),
            if (a11y.mensagemErroVoz != null) ...[
              const SizedBox(height: 8),
              Text(
                a11y.mensagemErroVoz!,
                style: const TextStyle(fontSize: 12, color: Colors.orangeAccent),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              a11y.estaOuvindo
                  ? 'Ouvindo… fale agora. Toque no microfone de novo para enviar.'
                  : 'Microfone: toque, fale e toque de novo para enviar por voz.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9EA9C2),
                height: 1.4,
              ),
            ),
            if (a11y.transcricaoParcial.isNotEmpty) ...[
              const SizedBox(height: 8),
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
        ),
      ),
    );
  }
}
