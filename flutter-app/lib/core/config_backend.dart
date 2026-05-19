import 'package:flutter/foundation.dart';

/// Configuração central do backend VisionGuide (FastAPI / Python).
/// Porta padrão alinhada com `backend/.env` → PORT=3001
///
/// Na web, o host segue o endereço em que o app foi aberto (ex.: IP da rede
/// local no celular). Assim o login aponta para o mesmo PC que roda `python main.py`.
class ConfigBackend {
  ConfigBackend._();

  static const int porta = 3001;

  static String? _hostManual;

  /// Permite forçar o host (útil em testes). Ex.: `ConfigBackend.definirHost('192.168.0.10')`
  static void definirHost(String host) {
    _hostManual = host.trim();
  }

  static String get host {
    if (_hostManual != null && _hostManual!.isNotEmpty) {
      return _hostManual!;
    }

    if (kIsWeb) {
      final hostPagina = Uri.base.host;
      if (hostPagina.isNotEmpty) {
        return hostPagina;
      }
      return 'localhost';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '10.0.2.2';
      default:
        return 'localhost';
    }
  }

  static String get urlBase => 'http://$host:$porta';

  static String get urlAuth => '$urlBase/auth';

  static String get urlAnalyze => '$urlBase/analyze';

  static String get urlHealth => '$urlBase/health';

  static String get urlWsChat {
    final esquema = kIsWeb && Uri.base.scheme == 'https' ? 'wss' : 'ws';
    return '$esquema://$host:$porta/ws/chat';
  }
}
