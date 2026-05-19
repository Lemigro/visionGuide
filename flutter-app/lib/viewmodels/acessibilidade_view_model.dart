import 'package:flutter/foundation.dart';

import '../services/servico_voz.dart';

class AcessibilidadeViewModel extends ChangeNotifier {
  AcessibilidadeViewModel({ServicoVoz? servicoVoz})
      : _servicoVoz = servicoVoz ?? ServicoVoz();

  final ServicoVoz _servicoVoz;

  bool leituraAutomatica = true;
  bool fonteAmpliada = false;
  bool envioAutomaticoPorVoz = true;
  String transcricaoParcial = '';
  String? mensagemErroVoz;

  bool get estaOuvindo => _servicoVoz.estaOuvindo;
  bool get estaFalando => _servicoVoz.estaFalando;
  bool get vozDisponivel => _servicoVoz.sttDisponivel;
  bool get leituraDisponivel => _servicoVoz.ttsDisponivel;
  bool get executandoNaWeb => _servicoVoz.executandoNaWeb;

  double get escalaFonte => fonteAmpliada ? 1.28 : 1.0;

  Future<void> inicializar() async {
    await _servicoVoz.inicializar();
    notifyListeners();
  }

  void alternarLeituraAutomatica(bool valor) {
    leituraAutomatica = valor;
    if (!valor) {
      _servicoVoz.pararFala();
    }
    notifyListeners();
  }

  void alternarFonteAmpliada(bool valor) {
    fonteAmpliada = valor;
    notifyListeners();
  }

  void alternarEnvioAutomaticoPorVoz(bool valor) {
    envioAutomaticoPorVoz = valor;
    notifyListeners();
  }

  Future<void> lerTexto(String texto) async {
    if (!leituraAutomatica || texto.trim().isEmpty) return;
    final ok = await _servicoVoz.falar(texto);
    if (!ok && executandoNaWeb) {
      mensagemErroVoz =
          'No Chrome, toque em "Testar voz" uma vez antes da leitura automática.';
    }
    notifyListeners();
  }

  Future<void> lerTextoManual(String texto) async {
    await _servicoVoz.pararFala();
    if (executandoNaWeb) {
      await _servicoVoz.desbloquearVozWeb();
    }
    final ok = await _servicoVoz.falar(texto);
    if (!ok) {
      mensagemErroVoz = _servicoVoz.ultimoErroTts ??
          'Não foi possível ler em voz alta. Verifique o volume do sistema.';
    } else {
      mensagemErroVoz = null;
    }
    notifyListeners();
  }

  Future<bool> testarVoz() async {
    mensagemErroVoz = null;
    final ok = await _servicoVoz.testarVoz();
    if (!ok) {
      mensagemErroVoz = _servicoVoz.ultimoErroTts ??
          'Teste de voz falhou. Confira o volume e as permissões do Chrome.';
    }
    notifyListeners();
    return ok;
  }

  Future<void> pararLeitura() async {
    await _servicoVoz.pararFala();
    notifyListeners();
  }

  Future<String?> alternarGravacaoVoz({
    required void Function(String texto) aoEnviarTexto,
    void Function(String parcial)? aoParcial,
  }) async {
    mensagemErroVoz = null;

    if (_servicoVoz.estaOuvindo) {
      await _servicoVoz.pararOuvindo(
        aoFinalizado: (texto) {
          transcricaoParcial = '';
          notifyListeners();
          if (texto.trim().isNotEmpty) {
            aoEnviarTexto(texto.trim());
          }
        },
      );
      notifyListeners();
      return null;
    }

    transcricaoParcial = '';
    notifyListeners();

    final erro = await _servicoVoz.iniciarOuvindo(
      aoParcial: (parcial) {
        transcricaoParcial = parcial;
        aoParcial?.call(parcial);
        notifyListeners();
      },
      aoFinalizado: (finalizado) {
        transcricaoParcial = '';
        notifyListeners();
        if (finalizado.trim().isNotEmpty) {
          aoEnviarTexto(finalizado.trim());
        }
      },
    );

    if (erro != null) {
      mensagemErroVoz = erro;
      notifyListeners();
      return erro;
    }

    notifyListeners();
    return null;
  }

  @override
  void dispose() {
    _servicoVoz.encerrar();
    super.dispose();
  }
}
