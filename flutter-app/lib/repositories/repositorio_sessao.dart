import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessaoSalva {
  const SessaoSalva({
    required this.token,
    required this.usuario,
  });

  final String token;
  final Map<String, dynamic> usuario;
}

class RepositorioSessao {
  static const _chaveToken = 'auth_token';
  static const _chaveUsuario = 'auth_usuario';

  Future<SessaoSalva?> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_chaveToken);
    final usuarioJson = prefs.getString(_chaveUsuario);
    if (token == null || token.isEmpty || usuarioJson == null) {
      return null;
    }

    try {
      final usuario = jsonDecode(usuarioJson) as Map<String, dynamic>;
      return SessaoSalva(token: token, usuario: usuario);
    } catch (_) {
      await limpar();
      return null;
    }
  }

  Future<void> salvar({
    required String token,
    required Map<String, dynamic> usuario,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveToken, token);
    await prefs.setString(_chaveUsuario, jsonEncode(usuario));
  }

  Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveToken);
    await prefs.remove(_chaveUsuario);
  }
}
