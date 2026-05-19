import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'etiqueta_mini.dart';

class AbaCamera extends StatelessWidget {
  const AbaCamera({
    super.key,
    required this.aoCapturarEEnviar,
    required this.aoAnalisar,
    required this.aoModoContinuo,
  });

  final Future<void> Function() aoCapturarEEnviar;
  final Future<void> Function() aoAnalisar;
  final VoidCallback aoModoContinuo;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('camera'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text(
          'Câmera assistiva',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Espaço reservado para integração com câmera, OCR e visão computacional.',
        ),
        const SizedBox(height: 14),
        Container(
          height: 470,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF18253D), Color(0xFF07101D)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.2, -0.3),
                      radius: 1,
                      colors: [const Color(0x3363A7FF), Colors.transparent],
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 18,
                top: 18,
                child: EtiquetaMini(texto: 'Preview ao vivo'),
              ),
              const Center(
                child: Icon(
                  Icons.center_focus_strong_rounded,
                  size: 112,
                  color: Colors.white70,
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xC208111F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Text(
                    'Aponte o celular para um texto, objeto ou obstáculo.\n'
                    'Aqui entra a câmera real quando a integração estiver pronta.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: aoAnalisar,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Analisar agora'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: aoModoContinuo,
                icon: const Icon(Icons.autorenew_rounded),
                label: const Text('Modo contínuo'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: aoCapturarEEnviar,
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('Capturar e enviar ao chat IA'),
        ),
      ],
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.03, end: 0);
  }
}
