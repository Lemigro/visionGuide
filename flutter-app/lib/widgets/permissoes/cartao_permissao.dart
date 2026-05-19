import 'package:flutter/material.dart';

class CartaoPermissao extends StatelessWidget {
  const CartaoPermissao({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.aoPressionar,
    this.textoBotao = 'Acessar as configurações',
  });

  final String titulo;
  final String subtitulo;
  final VoidCallback aoPressionar;
  final String textoBotao;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A4D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: aoPressionar,
              child: Text(textoBotao),
            ),
          ),
        ],
      ),
    );
  }
}
