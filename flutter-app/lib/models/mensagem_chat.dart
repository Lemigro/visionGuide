import 'dart:typed_data';

import 'papel_chat.dart';

class MensagemChat {
  const MensagemChat({
    required this.papel,
    required this.texto,
    this.bytesImagem,
  });

  final PapelChat papel;
  final String texto;
  final Uint8List? bytesImagem;
}
