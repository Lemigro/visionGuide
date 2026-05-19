import 'package:flutter/material.dart';

import '../models/acao_rapida.dart';
import '../models/destino_acao_rapida.dart';

class ConteudoInicio {
  ConteudoInicio._();

  static const atalhosRapidos = <AcaoRapida>[
    AcaoRapida(
      titulo: 'Descrever o ambiente',
      subtitulo: 'Captura e fala o que está na sua frente',
      icone: Icons.visibility_outlined,
      destino: DestinoAcaoRapida.camera,
    ),
    AcaoRapida(
      titulo: 'Ler texto ou placa',
      subtitulo: 'Aponte a câmera para avisos e letreiros',
      icone: Icons.document_scanner_outlined,
      destino: DestinoAcaoRapida.camera,
    ),
    AcaoRapida(
      titulo: 'Perguntar ao assistente',
      subtitulo: 'Tire dúvidas por voz ou texto',
      icone: Icons.record_voice_over_outlined,
      destino: DestinoAcaoRapida.assistente,
    ),
  ];
}
