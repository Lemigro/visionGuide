import 'package:flutter/material.dart';

import '../logo_vision_guide.dart';

class CabecalhoApp extends StatelessWidget {
  const CabecalhoApp({
    super.key,
    required this.subtitulo,
    required this.etiqueta,
  });

  final String subtitulo;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const LogoVisionGuide(largura: 118),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              subtitulo,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: const Color(0xFF9EA9C2), height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x1A63A7FF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x3363A7FF)),
            ),
            child: Text(etiqueta),
          ),
        ],
      ),
    );
  }
}
