import 'package:flutter/material.dart';

import '../models/acao_rapida.dart';
import '../models/item_galeria.dart';

class ConteudoInicio {
  ConteudoInicio._();

  static const itensGaleria = <ItemGaleria>[
    ItemGaleria(titulo: 'Praia', tipo: 'Foto', cor: Color(0xFF63A7FF)),
    ItemGaleria(titulo: 'Floresta', tipo: 'Foto', cor: Color(0xFF7AD089)),
    ItemGaleria(titulo: 'Mar', tipo: 'Vídeo', cor: Color(0xFF42CBE2)),
    ItemGaleria(titulo: 'Cidade', tipo: 'Foto', cor: Color(0xFF9FA9C7)),
    ItemGaleria(titulo: 'Noite', tipo: 'Foto', cor: Color(0xFF6D7EFF)),
    ItemGaleria(titulo: 'Rua', tipo: 'Vídeo', cor: Color(0xFFF0A35C)),
  ];

  static const atalhosRapidos = <AcaoRapida>[
    AcaoRapida(
      titulo: 'Descrever ambiente',
      subtitulo: 'Leitura rápida do cenário',
      icone: Icons.visibility_outlined,
    ),
    AcaoRapida(
      titulo: 'Ler texto',
      subtitulo: 'Reconhecer placas e avisos',
      icone: Icons.document_scanner_outlined,
    ),
    AcaoRapida(
      titulo: 'Alertar obstáculos',
      subtitulo: 'Aviso de navegação em tempo real',
      icone: Icons.warning_amber_rounded,
    ),
  ];
}
