import 'package:flutter/foundation.dart';

/// Configuração central do backend VisionGuide (FastAPI / Python).
/// Porta padrão alinhada com `backend/.env` → PORT=3001
class ConfigBackend {
  ConfigBackend._();

  static const int porta = 3001;

  static String get host {
    if (kIsWeb) return 'localhost';
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

  static String get urlWsChat => 'ws://$host:$porta/ws/chat';
}
