import 'package:flutter/material.dart';

class EtiquetaMini extends StatelessWidget {
  const EtiquetaMini({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xB208111F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(texto, style: const TextStyle(fontSize: 12)),
    );
  }
}
