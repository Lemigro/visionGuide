import 'package:flutter/material.dart';

class ModalSobre extends StatelessWidget {
  const ModalSobre({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sobre VisionGuide',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Versão: 1.0.0', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          const Text(
            'Equipe de Desenvolvimento:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Pedro H. A. Nascimento\n'
            '• Laila Maria Silva Pereira\n'
            '• Yago Barbosa de Andrade Oliveira\n'
            '• José Luiz Henrique Pereira',
            style: TextStyle(color: Colors.white70, height: 1.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'Repositório: https://github.com/Lemigro/visionGuide',
            style: TextStyle(
              color: Color(0xFF7C5CFF),
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }
}
