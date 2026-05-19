import 'package:flutter/material.dart';

import 'destino_acao_rapida.dart';

class AcaoRapida {
  const AcaoRapida({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.destino,
  });

  final String titulo;
  final String subtitulo;
  final IconData icone;
  final DestinoAcaoRapida destino;
}
