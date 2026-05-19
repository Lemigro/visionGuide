import 'package:flutter/foundation.dart';

import '../repositories/repositorio_preferencias_acessibilidade.dart';
import '../services/servico_voz.dart';

class AcessibilidadeViewModel extends ChangeNotifier {
  AcessibilidadeViewModel({
    ServicoVoz? servicoVoz,
    RepositorioPreferenciasAcessibilidade? preferencias,
  })  : _servicoVoz = servicoVoz ?? ServicoVoz(),
        _preferencias =
            preferencias ?? RepositorioPreferenciasAcessibilidade();

  final ServicoVoz _servicoVoz;
  final RepositorioPreferenciasAcessibilidade _preferencias;

  bool leituraAutomatica = true;
  bool fonteAmpliada = false;
  bool envioAutomaticoPorVoz = true;
  double velocidadeFala = 0.5;
  bool anunciarTelas = true;
  bool botoesGrandes = true;
  bool altoContraste = false;
  String transcricaoParcial = '';
  String? mensagemErroVoz;

  static const orientacaoInicial =
      'Vision Guide, seu assistente visual. '
      'Na tela inicial, escolha descrever o ambiente com a câmera '
      'ou falar com o assistente. Use os botões grandes no rodapé para mudar de tela.';

  bool get estaOuvindo => _servicoVoz.estaOuvindo;
  bool get estaFalando => _servicoVoz.estaFalando;
  bool get vozDisponivel => _servicoVoz.sttDisponivel;
  bool get leituraDisponivel => _servicoVoz.ttsDisponivel;
  bool get executandoNaWeb => _servicoVoz.executandoNaWeb;

  double get escalaFonte => fonteAmpliada ? 1.28 : 1.0;

  String get rotuloVelocidadeFala {
    if (velocidadeFala <= 0.25) return 'Lenta';
    if (velocidadeFala <= 0.75) return 'Normal';
    return 'Rápida';
  }

  Future<void> inicializar() async {
    await _carregarPreferencias();
    await _servicoVoz.inicializar();
    await _servicoVoz.aplicarVelocidadeFala(velocidadeFala);
    notifyListeners();
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await _preferencias.carregar();
    leituraAutomatica = prefs.leituraAutomatica;
    fonteAmpliada = prefs.fonteAmpliada;
    envioAutomaticoPorVoz = prefs.envioAutomaticoPorVoz;
    velocidadeFala = prefs.velocidadeFala;
    anunciarTelas = prefs.anunciarTelas;
    botoesGrandes = prefs.botoesGrandes;
    altoContraste = prefs.altoContraste;
  }

  Future<void> _persistirPreferencias() async {
    await _preferencias.salvar(
      PreferenciasAcessibilidade(
        leituraAutomatica: leituraAutomatica,
        fonteAmpliada: fonteAmpliada,
        envioAutomaticoPorVoz: envioAutomaticoPorVoz,
        velocidadeFala: velocidadeFala,
        anunciarTelas: anunciarTelas,
        botoesGrandes: botoesGrandes,
        altoContraste: altoContraste,
      ),
    );
  }

  void alternarAnunciarTelas(bool valor) {
    anunciarTelas = valor;
    notifyListeners();
    _persistirPreferencias();
  }

  void alternarBotoesGrandes(bool valor) {
    botoesGrandes = valor;
    notifyListeners();
    _persistirPreferencias();
  }

  void alternarAltoContraste(bool valor) {
    altoContraste = valor;
    notifyListeners();
    _persistirPreferencias();
  }

  String? _ultimoAnuncioTela;
  DateTime? _ultimoAnuncioTelaEm;

  Future<void> anunciarTela(String texto) async {
    if (!anunciarTelas || texto.trim().isEmpty) return;
    await lerTextoManual(texto);
  }

  /// Anuncia a aba no mesmo toque (rodapé, botões). Evita perder o gesto no Chrome.
  Future<void> anunciarTelaNaAcaoDoUsuario(String texto) async {
    if (!anunciarTelas || texto.trim().isEmpty) return;

    final normalizado = texto.trim();
    final agora = DateTime.now();
    if (_ultimoAnuncioTela == normalizado &&
        _ultimoAnuncioTelaEm != null &&
        agora.difference(_ultimoAnuncioTelaEm!) <
            const Duration(milliseconds: 600)) {
      return;
    }
    _ultimoAnuncioTela = normalizado;
    _ultimoAnuncioTelaEm = agora;

    final ok = await _servicoVoz.falarNaAcaoDoUsuario(normalizado);
    if (!ok) {
      mensagemErroVoz = _servicoVoz.ultimoErroTts ??
          'Não foi possível ler em voz alta. Verifique o volume do sistema.';
    } else {
      mensagemErroVoz = null;
    }
    notifyListeners();
  }

  Future<void> anunciarOrientacaoInicial() async {
    await anunciarTela(orientacaoInicial);
  }

  void alternarLeituraAutomatica(bool valor) {
    leituraAutomatica = valor;
    if (!valor) {
      _servicoVoz.pararFala();
    }
    notifyListeners();
    _persistirPreferencias();
  }

  void alternarFonteAmpliada(bool valor) {
    fonteAmpliada = valor;
    notifyListeners();
    _persistirPreferencias();
  }

  void alternarEnvioAutomaticoPorVoz(bool valor) {
    envioAutomaticoPorVoz = valor;
    notifyListeners();
    _persistirPreferencias();
  }

  Future<void> definirVelocidadeFala(double valor) async {
    velocidadeFala = valor.clamp(0.0, 1.0);
    await _servicoVoz.aplicarVelocidadeFala(velocidadeFala);
    notifyListeners();
    await _persistirPreferencias();
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

  void _aoTerminarGravacao(
    String texto,
    void Function(String texto) aoEnviarTexto,
  ) {
    transcricaoParcial = '';
    final limpo = texto.trim();
    if (limpo.isNotEmpty) {
      mensagemErroVoz = null;
      aoEnviarTexto(limpo);
    } else {
      mensagemErroVoz =
          'Não captei sua fala. Toque no microfone, fale e toque de novo para enviar.';
    }
    notifyListeners();
  }

  Future<String?> alternarGravacaoVoz({
    required void Function(String texto) aoEnviarTexto,
    void Function(String parcial)? aoParcial,
  }) async {
    mensagemErroVoz = null;

    if (_servicoVoz.estaOuvindo) {
      await _servicoVoz.pararOuvindo(
        aoFinalizado: (texto) => _aoTerminarGravacao(texto, aoEnviarTexto),
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
      aoFinalizado: (finalizado) =>
          _aoTerminarGravacao(finalizado, aoEnviarTexto),
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
