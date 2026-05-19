import 'package:flutter/material.dart';

class LinhaChip extends StatelessWidget {
  const LinhaChip({
    super.key,
    required this.rotulo,
    required this.valor,
  });

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(rotulo, style: const TextStyle(color: Color(0xFF9EA9C2))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x1A63A7FF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(valor),
        ),
      ],
    );
  }
}
