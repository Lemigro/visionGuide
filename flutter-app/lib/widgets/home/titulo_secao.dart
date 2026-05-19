import 'package:flutter/material.dart';

class TituloSecao extends StatelessWidget {
  const TituloSecao({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.aoVerTudo,
  });

  final String titulo;
  final String subtitulo;
  final VoidCallback? aoVerTudo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: const TextStyle(color: Color(0xFF9EA9C2), fontSize: 12),
            ),
          ],
        ),
        if (aoVerTudo != null)
          TextButton(onPressed: aoVerTudo, child: const Text('Ver tudo')),
      ],
    );
  }
}
