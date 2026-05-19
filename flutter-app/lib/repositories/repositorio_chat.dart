import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

typedef OuvinteEventoChat = void Function(Map<String, dynamic> evento);

class RepositorioChat {
  WebSocketChannel? _canal;

  bool get conectado => _canal != null;

  void conectar({
    required Uri url,
    required OuvinteEventoChat aoEvento,
    void Function(Object)? aoErro,
    void Function()? aoFechar,
  }) {
    fechar();
    _canal = WebSocketChannel.connect(url);
    _canal!.stream.listen(
      (mensagem) {
        try {
          final evento =
              jsonDecode(mensagem as String) as Map<String, dynamic>;
          aoEvento(evento);
        } catch (_) {
          // mensagem inválida ignorada
        }
      },
      onError: aoErro,
      onDone: aoFechar,
    );
  }

  bool enviarMensagem({
    required String texto,
    String? imagemBase64,
  }) {
    final canal = _canal;
    if (canal == null) return false;

    final payload = <String, dynamic>{
      'type': 'message',
      'content': texto,
    };

    if (imagemBase64 != null && imagemBase64.isNotEmpty) {
      payload['image'] = imagemBase64.startsWith('data:')
          ? imagemBase64
          : 'data:image/jpeg;base64,$imagemBase64';
    }

    canal.sink.add(jsonEncode(payload));
    return true;
  }

  void fechar() {
    _canal?.sink.close();
    _canal = null;
  }
}
