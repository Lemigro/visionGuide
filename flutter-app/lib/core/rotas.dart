import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/tela_carregamento.dart';
import '../screens/tela_entrar.dart';
import '../screens/tela_registrar.dart';
import '../screens/vision_guide_home.dart';
import '../screens/tela_perfil.dart';
import '../viewmodels/autenticacao_view_model.dart';

const _rotasPublicas = ['/carregamento', '/entrar', '/registrar'];

GoRouter criarRotasApp(AutenticacaoViewModel autenticacao) {
  return GoRouter(
    initialLocation: '/carregamento',
    debugLogDiagnostics: true,
    refreshListenable: autenticacao,
    redirect: (context, state) {
      final auth = autenticacao;
      final path = state.uri.path;

      if (path.isEmpty || path == '/') {
        return '/carregamento';
      }

      if (!auth.sessaoVerificada) {
        return null;
      }

      if (path == '/carregamento') {
        return auth.estaAutenticado ? '/inicio' : '/entrar';
      }

      if (auth.estaAutenticado &&
          (path == '/entrar' || path == '/registrar')) {
        return '/inicio';
      }

      if (!auth.estaAutenticado && !_rotasPublicas.contains(path)) {
        return '/entrar';
      }

      return null;
    },
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
    ],
  );
}

/// Mantido para compatibilidade; prefira [criarRotasApp] com instância única.
GoRouter rotasApp() {
  throw UnsupportedError(
    'Use criarRotasApp(autenticacao) uma única vez no VisionGuideApp.',
  );
}
