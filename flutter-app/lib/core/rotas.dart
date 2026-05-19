import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/tela_carregamento.dart';
import '../screens/tela_entrar.dart';
import '../screens/tela_registrar.dart';
import '../screens/vision_guide_home.dart';
import '../screens/tela_perfil.dart';
import '../screens/tela_permissoes_backend.dart';

GoRouter rotasApp() {
  return GoRouter(
    initialLocation: '/carregamento',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF08111F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Rota não encontrada: ${state.uri.path}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
    redirect: (context, state) {
      final path = state.uri.path;
      if (path.isEmpty || path == '/') {
        return '/carregamento';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/carregamento',
        builder: (context, state) => const TelaCarregamento(),
      ),
      GoRoute(
        path: '/entrar',
        builder: (context, state) => const TelaEntrar(),
      ),
      GoRoute(
        path: '/registrar',
        builder: (context, state) => const TelaRegistrar(),
      ),
      GoRoute(
        path: '/inicio',
        builder: (context, state) => const VisionGuideHome(),
      ),
      GoRoute(
        path: '/perfil',
        builder: (context, state) => const TelaPerfil(),
      ),
      GoRoute(
        path: '/permissoes-backend',
        builder: (context, state) => const TelaPermissoesBackend(),
      ),
    ],
  );
}
