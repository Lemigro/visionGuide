import 'package:flutter/material.dart';

class CartaoOpcao extends StatelessWidget {
  const CartaoOpcao({
    super.key,
    required this.titulo,
    required this.icone,
    required this.aoTocar,
  });

  final String titulo;
  final IconData icone;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252A4D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icone, color: const Color(0xFF7C5CFF), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
          ],
        ),
      ),
    );
  }
}
