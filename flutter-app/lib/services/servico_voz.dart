import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

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
          _estaOuvindo = false;
        }
      },
      onError: (erro) => debugPrint('STT erro: $erro'),
    );

    if (_sttDisponivel) {
      _localeStt = await _resolverLocalePortugues();
    }

    await _configurarTts();
    _inicializado = true;
  }

  Future<void> _configurarTts() async {
    try {
      if (kIsWeb) {
        await _tts.setSpeechRate(0.95);
        await _tts.setPitch(1.0);
        await _tts.setVolume(1.0);
        await _tts.awaitSpeakCompletion(false);
        await _selecionarVozPortuguesWeb();
      } else {
        await _tts.setLanguage('pt-BR');
        await _tts.setSpeechRate(0.48);
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

  Future<String?> iniciarOuvindo({
    required void Function(String parcial) aoParcial,
    required void Function(String finalizado) aoFinalizado,
  }) async {
    if (!_sttDisponivel) {
      return kIsWeb
          ? 'No Chrome, permita o microfone quando o navegador pedir. '
              'Use https ou localhost e prefira o Google Chrome.'
          : 'Reconhecimento de voz indisponível neste dispositivo.';
    }

    if (kIsWeb) {
      await desbloquearVozWeb();
    }

    if (_estaOuvindo) {
      await pararOuvindo(aoFinalizado: aoFinalizado);
      return null;
    }

    final temPermissao = await _stt.hasPermission;
    if (temPermissao != true) {
      return kIsWeb
          ? 'Microfone bloqueado. Clique no cadeado na barra de endereço do Chrome '
              'e permita o microfone para este site.'
          : 'Permissão do microfone negada.';
    }

    var ultimoTexto = '';
    var finalEnviado = false;
    _estaOuvindo = true;

    await _stt.listen(
      localeId: _localeStt,
      listenFor: const Duration(seconds: 45),
      pauseFor: const Duration(seconds: 2),
      onResult: (SpeechRecognitionResult result) {
        ultimoTexto = result.recognizedWords.trim();
        aoParcial(ultimoTexto);
        if (result.finalResult &&
            ultimoTexto.isNotEmpty &&
            !finalEnviado) {
          finalEnviado = true;
          _estaOuvindo = false;
          _stt.stop();
          aoFinalizado(ultimoTexto);
        }
      },
    );

    return null;
  }

  Future<void> pararOuvindo({
    required void Function(String finalizado) aoFinalizado,
  }) async {
    if (!_estaOuvindo) return;

    final textoAtual = _stt.lastRecognizedWords.trim();
    await _stt.stop();
    _estaOuvindo = false;

    if (textoAtual.isNotEmpty) {
      aoFinalizado(textoAtual);
    }
  }

  Future<void> encerrar() async {
    await pararFala();
    if (_estaOuvindo) {
      await _stt.stop();
      _estaOuvindo = false;
    }
  }
}
