import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasAcessibilidade {
  const PreferenciasAcessibilidade({
    required this.leituraAutomatica,
    required this.fonteAmpliada,
    required this.envioAutomaticoPorVoz,
    required this.velocidadeFala,
    required this.anunciarTelas,
    required this.botoesGrandes,
    required this.altoContraste,
  });

  final bool leituraAutomatica;
  final bool fonteAmpliada;
  final bool envioAutomaticoPorVoz;
  final double velocidadeFala;
  final bool anunciarTelas;
  final bool botoesGrandes;
  final bool altoContraste;

  static const padrao = PreferenciasAcessibilidade(
    leituraAutomatica: true,
    fonteAmpliada: false,
    envioAutomaticoPorVoz: true,
    velocidadeFala: 0.5,
    anunciarTelas: true,
    botoesGrandes: true,
    altoContraste: false,
  );
}

class RepositorioPreferenciasAcessibilidade {
  static const _leituraAutomatica = 'a11y_leitura_automatica';
  static const _fonteAmpliada = 'a11y_fonte_ampliada';
  static const _envioAutomaticoPorVoz = 'a11y_envio_automatico_voz';
  static const _velocidadeFala = 'a11y_velocidade_fala';
  static const _anunciarTelas = 'a11y_anunciar_telas';
  static const _botoesGrandes = 'a11y_botoes_grandes';
  static const _altoContraste = 'a11y_alto_contraste';

  Future<PreferenciasAcessibilidade> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final padrao = PreferenciasAcessibilidade.padrao;

    return PreferenciasAcessibilidade(
      leituraAutomatica:
          prefs.getBool(_leituraAutomatica) ?? padrao.leituraAutomatica,
      fonteAmpliada: prefs.getBool(_fonteAmpliada) ?? padrao.fonteAmpliada,
      envioAutomaticoPorVoz: prefs.getBool(_envioAutomaticoPorVoz) ??
          padrao.envioAutomaticoPorVoz,
      velocidadeFala:
          prefs.getDouble(_velocidadeFala) ?? padrao.velocidadeFala,
      anunciarTelas: prefs.getBool(_anunciarTelas) ?? padrao.anunciarTelas,
      botoesGrandes: prefs.getBool(_botoesGrandes) ?? padrao.botoesGrandes,
      altoContraste: prefs.getBool(_altoContraste) ?? padrao.altoContraste,
    );
  }

  Future<void> salvar(PreferenciasAcessibilidade prefs) async {
    final storage = await SharedPreferences.getInstance();
    await storage.setBool(_leituraAutomatica, prefs.leituraAutomatica);
    await storage.setBool(_fonteAmpliada, prefs.fonteAmpliada);
    await storage.setBool(_envioAutomaticoPorVoz, prefs.envioAutomaticoPorVoz);
    await storage.setDouble(_velocidadeFala, prefs.velocidadeFala);
    await storage.setBool(_anunciarTelas, prefs.anunciarTelas);
    await storage.setBool(_botoesGrandes, prefs.botoesGrandes);
    await storage.setBool(_altoContraste, prefs.altoContraste);
  }
}
