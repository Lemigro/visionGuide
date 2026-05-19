import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/config_backend.dart';
import '../models/mensagem_chat.dart';
import '../models/papel_chat.dart';
import '../repositories/repositorio_chat.dart';
import 'acessibilidade_view_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    RepositorioChat? repositorioChat,
    ImagePicker? seletorImagem,
    AcessibilidadeViewModel? acessibilidade,
  })  : _repositorioChat = repositorioChat ?? RepositorioChat(),
        _seletorImagem = seletorImagem ?? ImagePicker(),
        _acessibilidade = acessibilidade;

  final RepositorioChat _repositorioChat;
  final ImagePicker _seletorImagem;
  final AcessibilidadeViewModel? _acessibilidade;

  static const _mensagemBoasVindas =
      'Olá! Sou o assistente visual VisionGuide. '
      'Use o microfone para falar, envie uma foto ou use a câmera assistiva. '
      'Leio as respostas em voz alta para você.';

  int indiceAba = 0;
  bool aguardandoResposta = false;
  bool solicitarRolagem = false;
  bool _esperandoRespostaAssistente = false;

  Timer? _timeoutRespostaAssistente;

  final List<MensagemChat> mensagens = [
    MensagemChat(papel: PapelChat.assistente, texto: _mensagemBoasVindas),
  ];

  void inicializar() {
    _repositorioChat.conectar(
      url: Uri.parse(ConfigBackend.urlWsChat),
      aoEvento: _processarEventoWebSocket,
      aoErro: (erro) => debugPrint('Erro no WebSocket: $erro'),
      aoFechar: () => debugPrint('WebSocket fechado'),
    );
  }

  void _processarEventoWebSocket(Map<String, dynamic> evento) {
    final tipo = evento['type'] as String?;

    if (tipo == 'typing') {
      if (_esperandoRespostaAssistente) {
        aguardandoResposta = true;
        notifyListeners();
      }
      return;
    }

    if (tipo != 'message') return;

    final conteudo = evento['content'];
    if (conteudo is! String || conteudo.isEmpty) return;

    final papelRaw = evento['role'] as String?;
    if (papelRaw == 'system') return;

    final papel =
        papelRaw == 'user' ? PapelChat.usuario : PapelChat.assistente;

    if (papel == PapelChat.assistente && !_esperandoRespostaAssistente) {
      final duplicataBoasVindas = mensagens.any(
        (m) =>
            m.papel == PapelChat.assistente &&
            m.texto.contains('assistente visual VisionGuide'),
      );
      if (duplicataBoasVindas && conteudo.contains('assistente visual VisionGuide')) {
        return;
      }
    }

    _finalizarEsperaAssistente();
    mensagens.add(MensagemChat(papel: papel, texto: conteudo));
    if (papel == PapelChat.assistente) {
      _acessibilidade?.lerTexto(conteudo);
    }
    solicitarRolagem = true;
    notifyListeners();
  }

  void lerUltimaRespostaAssistente() {
    for (var i = mensagens.length - 1; i >= 0; i--) {
      if (mensagens[i].papel == PapelChat.assistente) {
        _acessibilidade?.lerTextoManual(mensagens[i].texto);
        return;
      }
    }
  }

  void _finalizarEsperaAssistente() {
    _timeoutRespostaAssistente?.cancel();
    _timeoutRespostaAssistente = null;
    _esperandoRespostaAssistente = false;
    aguardandoResposta = false;
  }

  void _iniciarEsperaAssistente() {
    _esperandoRespostaAssistente = true;
    aguardandoResposta = true;
    _timeoutRespostaAssistente?.cancel();
    _timeoutRespostaAssistente = Timer(const Duration(seconds: 45), () {
      if (!_esperandoRespostaAssistente) return;
      _finalizarEsperaAssistente();
      mensagens.add(
        const MensagemChat(
          papel: PapelChat.assistente,
          texto:
              'A resposta demorou mais que o esperado. Tente enviar a mensagem novamente.',
        ),
      );
      solicitarRolagem = true;
      notifyListeners();
    });
  }

  void definirAba(int indice) {
    indiceAba = indice;
    if (indice == 2) {
      solicitarRolagem = true;
    }
    notifyListeners();
  }

  void abrirCamera() => definirAba(1);
  void abrirChat() => definirAba(2);
  void abrirGaleria() => definirAba(3);

  void marcarRolagemConcluida() {
    solicitarRolagem = false;
  }

  String get etiquetaAba {
    switch (indiceAba) {
      case 1:
        return 'Câmera';
      case 2:
        return 'IA';
      case 3:
        return 'Galeria';
      case 4:
        return 'Perfil';
      default:
        return 'Início';
    }
  }

  void enviarMensagem(String texto) {
    final mensagem = texto.trim();
    if (mensagem.isEmpty) return;

    mensagens.add(MensagemChat(papel: PapelChat.usuario, texto: mensagem));
    _iniciarEsperaAssistente();
    solicitarRolagem = true;
    notifyListeners();

    final enviado = _repositorioChat.enviarMensagem(texto: mensagem);
    if (enviado) return;

    _finalizarEsperaAssistente();
    mensagens.add(
      MensagemChat(
        papel: PapelChat.assistente,
        texto:
            'Sem conexão com o servidor. Verifique se o backend Python está em ${ConfigBackend.urlBase}.',
      ),
    );
    solicitarRolagem = true;
    notifyListeners();
  }

  Future<String?> enviarImagemParaAssistente(
    List<int> bytes, {
    String? legenda,
  }) async {
    final texto = (legenda != null && legenda.trim().isNotEmpty)
        ? legenda.trim()
        : 'Descreva o que há nesta imagem.';

    mensagens.add(
      MensagemChat(
        papel: PapelChat.usuario,
        texto: texto,
        bytesImagem: Uint8List.fromList(bytes),
      ),
    );
    indiceAba = 2;
    _iniciarEsperaAssistente();
    solicitarRolagem = true;
    notifyListeners();

    final enviado = _repositorioChat.enviarMensagem(
      texto: texto,
      imagemBase64: base64Encode(bytes),
    );

    if (enviado) return null;

    _finalizarEsperaAssistente();
    mensagens.add(
      MensagemChat(
        papel: PapelChat.assistente,
        texto:
            'Sem conexão com o servidor. Verifique se o backend Python está em ${ConfigBackend.urlBase}.',
      ),
    );
    solicitarRolagem = true;
    notifyListeners();
    return null;
  }

  Future<String?> capturarEAnalisarImagem() async {
    try {
      final captura = await _seletorImagem.pickImage(
        source: ImageSource.camera,
        imageQuality: 72,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (captura == null) return null;

      final bytes = await captura.readAsBytes();
      return enviarImagemParaAssistente(
        bytes,
        legenda: 'Descreva o ambiente capturado pela câmera.',
      );
    } catch (_) {
      return 'Não foi possível abrir a câmera agora.';
    }
  }

  Future<String?> enviarImagemDaGaleria() async {
    try {
      final captura = await _seletorImagem.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (captura == null) return null;

      final bytes = await captura.readAsBytes();
      return enviarImagemParaAssistente(
        bytes,
        legenda: 'Descreva esta imagem em detalhes.',
      );
    } catch (_) {
      return 'Não foi possível abrir a galeria agora.';
    }
  }

  @override
  void dispose() {
    _timeoutRespostaAssistente?.cancel();
    _repositorioChat.fechar();
    super.dispose();
  }
}
