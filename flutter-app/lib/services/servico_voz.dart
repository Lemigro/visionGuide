import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ServicoVoz {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _inicializado = false;
  bool _sttDisponivel = false;
  bool _ttsDisponivel = false;
  bool _estaOuvindo = false;
  bool _estaFalando = false;
  bool _vozWebDesbloqueada = false;
  String? _localeStt;
  String? _ultimoErroTts;
  double _indiceVelocidade = 0.5;
  String _textoSessaoAtual = '';
  bool _finalSessaoEnviado = false;
  void Function(String finalizado)? _aoFinalizadoSessao;
  void Function(String parcial)? _aoParcialSessao;
  int? _inicioOuvindoMs;
  SpeechRecognitionError? _ultimoErroStt;

  bool get sttDisponivel => _sttDisponivel;
  bool get ttsDisponivel => _ttsDisponivel;
  bool get estaOuvindo => _estaOuvindo;
  bool get estaFalando => _estaFalando;
  bool get executandoNaWeb => kIsWeb;
  String? get ultimoErroTts => _ultimoErroTts;

  Future<void> inicializar() async {
    if (_inicializado) return;

    _sttDisponivel = await _stt.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _encerrarSessaoOuvindo();
        }
      },
      onError: (erro) {
        _ultimoErroStt = erro;
        debugPrint('STT erro: $erro');
        _encerrarSessaoOuvindo();
      },
    );

    if (_sttDisponivel) {
      _localeStt = await _resolverLocalePortugues();
    }

    await _configurarTts();
    _inicializado = true;
  }

  Future<void> aplicarVelocidadeFala(double indice) async {
    _indiceVelocidade = indice.clamp(0.0, 1.0);
    if (!_inicializado) return;

    final taxa = kIsWeb
        ? 0.75 + (_indiceVelocidade * 0.35)
        : 0.35 + (_indiceVelocidade * 0.25);
    await _tts.setSpeechRate(taxa);
  }

  Future<void> _configurarTts() async {
    try {
      if (kIsWeb) {
        await aplicarVelocidadeFala(_indiceVelocidade);
        await _tts.setPitch(1.0);
        await _tts.setVolume(1.0);
        await _tts.awaitSpeakCompletion(false);
        await _selecionarVozPortuguesWeb();
      } else {
        await _tts.setLanguage('pt-BR');
        await aplicarVelocidadeFala(_indiceVelocidade);
        await _tts.setPitch(1.0);
        await _tts.setVolume(1.0);
        await _tts.awaitSpeakCompletion(true);
      }

      _tts.setStartHandler(() => _estaFalando = true);
      _tts.setCompletionHandler(() => _estaFalando = false);
      _tts.setCancelHandler(() => _estaFalando = false);
      _tts.setErrorHandler((msg) {
        _ultimoErroTts = msg;
        _estaFalando = false;
        debugPrint('TTS erro: $msg');
      });

      _ttsDisponivel = true;
    } catch (e) {
      _ttsDisponivel = false;
      _ultimoErroTts = e.toString();
      debugPrint('Falha ao configurar TTS: $e');
    }
  }

  Future<void> _selecionarVozPortuguesWeb() async {
    final idiomas = await _tts.getLanguages;
    if (idiomas is List) {
      for (final codigo in ['pt-BR', 'pt_BR', 'pt-PT', 'pt']) {
        if (idiomas.contains(codigo)) {
          await _tts.setLanguage(codigo);
          break;
        }
      }
    }

    final vozes = await _tts.getVoices;
    if (vozes is! List) return;

    for (final voz in vozes) {
      if (voz is! Map) continue;
      final locale = voz['locale']?.toString().toLowerCase() ?? '';
      if (locale.startsWith('pt')) {
        await _tts.setVoice({
          'name': voz['name'],
          'locale': voz['locale'],
        });
        return;
      }
    }

    await _tts.setLanguage('pt-BR');
  }

  Future<String?> _resolverLocalePortugues() async {
    try {
      final locales = await _stt.locales();
      for (final locale in locales) {
        final id = locale.localeId.toLowerCase();
        if (id.startsWith('pt')) return locale.localeId;
      }
    } catch (e) {
      debugPrint('Erro ao listar locales STT: $e');
    }
    return kIsWeb ? 'pt-BR' : 'pt_BR';
  }

  /// No Chrome, a 1ª fala precisa ser após um toque do usuário (política do navegador).
  Future<void> desbloquearVozWeb() async {
    if (!kIsWeb || _vozWebDesbloqueada || !_ttsDisponivel) return;

    try {
      await _tts.setVolume(1.0);
      await _tts.speak('Pronto');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _tts.stop();
      _vozWebDesbloqueada = true;
      _ultimoErroTts = null;
    } catch (e) {
      _ultimoErroTts = e.toString();
    }
  }

  /// Fala no mesmo contexto do toque do usuário (necessário no Chrome).
  Future<bool> falarNaAcaoDoUsuario(String texto) async {
    if (texto.trim().isEmpty || !_ttsDisponivel) return false;

    try {
      if (kIsWeb) {
        var resultado = await _tts.speak(texto);
        if (resultado == 1 || resultado == 0) {
          _vozWebDesbloqueada = true;
          _ultimoErroTts = null;
          return true;
        }

        await desbloquearVozWeb();
        resultado = await _tts.speak(texto);
        _ultimoErroTts = null;
        return resultado == 1 || resultado == 0;
      }

      await pararFala();
      final resultado = await _tts.speak(texto);
      _ultimoErroTts = null;
      return resultado == 1;
    } catch (e) {
      _ultimoErroTts = e.toString();
      debugPrint('Erro ao falar na ação do usuário: $e');
      return false;
    }
  }

  Future<bool> falar(String texto) async {
    if (texto.trim().isEmpty || !_ttsDisponivel) return false;

    if (kIsWeb && !_vozWebDesbloqueada) {
      await desbloquearVozWeb();
    }

    try {
      await pararFala();
      final resultado = await _tts.speak(texto);
      _ultimoErroTts = null;

      if (kIsWeb && resultado == 0) {
        return true;
      }
      return resultado == 1 || resultado == 0;
    } catch (e) {
      _ultimoErroTts = e.toString();
      debugPrint('Erro ao falar: $e');
      return false;
    }
  }

  Future<bool> testarVoz() async {
    if (kIsWeb) {
      await desbloquearVozWeb();
    }
    return falar(
      'Vision Guide ativo. Leitura em voz alta funcionando no navegador.',
    );
  }

  Future<void> pararFala() async {
    if (_estaFalando) {
      await _tts.stop();
    }
    _estaFalando = false;
  }

  String get _textoReconhecidoAtual {
    if (_textoSessaoAtual.isNotEmpty) return _textoSessaoAtual;
    return _stt.lastRecognizedWords.trim();
  }

  void _encerrarSessaoOuvindo() {
    if (_finalSessaoEnviado) {
      _estaOuvindo = false;
      return;
    }
    if (_inicioOuvindoMs != null) {
      final decorrido =
          DateTime.now().millisecondsSinceEpoch - _inicioOuvindoMs!;
      if (decorrido < 350) return;
    }
    if (!_estaOuvindo && _aoFinalizadoSessao == null) return;

    final callback = _aoFinalizadoSessao;
    _estaOuvindo = false;
    _aoFinalizadoSessao = null;
    _aoParcialSessao = null;

    if (callback == null || _finalSessaoEnviado) {
      _textoSessaoAtual = '';
      return;
    }

    final texto = _textoReconhecidoAtual;
    _textoSessaoAtual = '';
    _finalSessaoEnviado = true;
    callback(texto);
  }

  void _limparSessaoOuvindo() {
    _estaOuvindo = false;
    _inicioOuvindoMs = null;
    _aoFinalizadoSessao = null;
    _aoParcialSessao = null;
    _textoSessaoAtual = '';
    _finalSessaoEnviado = false;
  }

  String _mensagemFalhaMicrofone() {
    final erro = _ultimoErroStt ?? _stt.lastError;
    final codigo = erro?.errorMsg.toLowerCase() ?? '';

    if (codigo.contains('not-allowed') || codigo.contains('service-not-allowed')) {
      return kIsWeb
          ? 'Microfone bloqueado. No Chrome, toque no cadeado ao lado do endereço '
              'e permita o microfone para este site.'
          : 'Permissão do microfone negada.';
    }
    if (codigo.contains('not-supported') || codigo.contains('speech_not_supported')) {
      return kIsWeb
          ? 'Seu navegador não suporta reconhecimento de voz. '
              'No celular, use o Google Chrome (Safari não funciona).'
          : 'Reconhecimento de voz indisponível neste dispositivo.';
    }
    if (codigo.contains('no-speech')) {
      return 'Não ouvi nada. Fale mais perto do microfone e tente de novo.';
    }
    if (codigo.contains('audio-capture')) {
      return 'Não consegui acessar o microfone. Feche outras abas que usem o mic e tente de novo.';
    }

    return kIsWeb
        ? 'Não foi possível iniciar o microfone. Use Google Chrome em localhost, '
            'permita o microfone e toque no botão de gravar de novo.'
        : 'Não foi possível iniciar o reconhecimento de voz.';
  }

  Future<String?> iniciarOuvindo({
    required void Function(String parcial) aoParcial,
    required void Function(String finalizado) aoFinalizado,
  }) async {
    if (!_sttDisponivel) {
      return _mensagemFalhaMicrofone();
    }

    if (_estaOuvindo) {
      await pararOuvindo(aoFinalizado: aoFinalizado);
      return null;
    }

    if (!kIsWeb) {
      final temPermissao = await _stt.hasPermission;
      if (temPermissao != true) {
        return 'Permissão do microfone negada.';
      }
    }

    _textoSessaoAtual = '';
    _finalSessaoEnviado = false;
    _ultimoErroStt = null;
    _aoParcialSessao = aoParcial;
    _aoFinalizadoSessao = aoFinalizado;

    try {
      await _stt.listen(
        onResult: (SpeechRecognitionResult result) {
          final texto = result.recognizedWords.trim();
          if (texto.isNotEmpty) {
            _textoSessaoAtual = texto;
            _aoParcialSessao?.call(texto);
          }
          if (result.finalResult &&
              texto.isNotEmpty &&
              !_finalSessaoEnviado) {
            unawaited(_stt.stop());
            _entregarTextoFinal(texto);
          }
        },
        localeId: _localeStt,
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: false,
        partialResults: true,
      );
    } on SpeechToTextNotInitializedException {
      _limparSessaoOuvindo();
      return 'Reconhecimento de voz não inicializado. Reinicie o app.';
    } on ListenFailedException {
      _limparSessaoOuvindo();
      return _mensagemFalhaMicrofone();
    }

    if (!_stt.isListening) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    if (!_stt.isListening) {
      _limparSessaoOuvindo();
      return _mensagemFalhaMicrofone();
    }

    _estaOuvindo = true;
    _inicioOuvindoMs = DateTime.now().millisecondsSinceEpoch;
    return null;
  }

  void _entregarTextoFinal(String texto) {
    if (_finalSessaoEnviado) return;

    final callback = _aoFinalizadoSessao;
    _finalSessaoEnviado = true;
    _estaOuvindo = false;
    _aoFinalizadoSessao = null;
    _aoParcialSessao = null;
    _textoSessaoAtual = '';
    callback?.call(texto);
  }

  Future<void> pararOuvindo({
    required void Function(String finalizado) aoFinalizado,
  }) async {
    if (!_estaOuvindo && !_finalSessaoEnviado) {
      final texto = _textoReconhecidoAtual;
      if (texto.isNotEmpty) {
        _finalSessaoEnviado = true;
        _aoFinalizadoSessao = null;
        _aoParcialSessao = null;
        _textoSessaoAtual = '';
        aoFinalizado(texto);
      }
      return;
    }

    if (_estaOuvindo) {
      await _stt.stop();
    }

    if (_finalSessaoEnviado) return;

    final texto = _textoReconhecidoAtual;
    _finalSessaoEnviado = true;
    _estaOuvindo = false;
    _inicioOuvindoMs = null;
    _aoFinalizadoSessao = null;
    _aoParcialSessao = null;
    _textoSessaoAtual = '';
    aoFinalizado(texto);
  }

  Future<void> encerrar() async {
    await pararFala();
    if (_estaOuvindo) {
      await _stt.stop();
    }
    _limparSessaoOuvindo();
  }
}
