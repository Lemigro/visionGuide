import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config_backend.dart';
import '../models/resposta_login_modelo.dart';

/// Camada de dados: chamadas HTTP de autenticação.
class ApiAutenticacao {
  static String get urlBase => ConfigBackend.urlAuth;

  static Future<bool> verificarServidor() async {
    try {
      final response = await http
          .get(Uri.parse(ConfigBackend.urlHealth))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static String extrairMensagemErro(Object? body, int statusCode) {
    if (body is Map<String, dynamic>) {
      final mensagem = body['mensagem'] ?? body['detail'];
      if (mensagem is String && mensagem.isNotEmpty) return mensagem;
      if (mensagem is List && mensagem.isNotEmpty) {
        return mensagem.first.toString();
      }
    }
    return 'Erro ao fazer login (HTTP $statusCode)';
  }

  static Future<RespostaLoginModelo> realizarLogin(
    String email,
    String senha,
  ) async {
    final emailNormalizado = email.trim().toLowerCase();

    try {
      final response = await http.post(
        Uri.parse('$urlBase/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailNormalizado,
          'senha': senha,
        }),
      ).timeout(const Duration(seconds: 15));

      Map<String, dynamic>? body;
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            body = decoded;
          }
        } catch (_) {
          return RespostaLoginModelo(
            status: false,
            mensagem:
                'Resposta inválida do servidor (HTTP ${response.statusCode}).',
          );
        }
      }

      if (response.statusCode == 200 && body != null) {
        return RespostaLoginModelo.fromJson(body);
      }

      return RespostaLoginModelo(
        status: false,
        mensagem: extrairMensagemErro(body, response.statusCode),
      );
    } catch (e) {
      return RespostaLoginModelo(
        status: false,
        mensagem:
            'Não foi possível conectar em ${ConfigBackend.urlAuth}. '
            'Confira se o backend está rodando (python main.py na pasta backend, '
            'porta ${ConfigBackend.porta}). Se abriu o app pelo celular, use o IP '
            'do computador na rede (ex.: http://192.168.x.x:porta do Flutter). '
            'Detalhe: $e',
      );
    }
  }

  static Future<RespostaLoginModelo> registrarUsuario({
    required String email,
    required String nome,
    required String senha,
    required String confirmacaoSenha,
    required String codigoOtp,
  }) async {
    try {
      if (senha != confirmacaoSenha) {
        return RespostaLoginModelo(
          status: false,
          mensagem: 'As senhas não coincidem',
        );
      }

      final response = await http.post(
        Uri.parse('$urlBase/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'nome': nome,
          'senha': senha,
          'codigoOtp': codigoOtp,
        }),
      );

      if (response.statusCode == 201) {
        return RespostaLoginModelo.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return RespostaLoginModelo(
        status: false,
        mensagem: 'Erro ao registrar: ${response.statusCode}',
      );
    } catch (e) {
      return RespostaLoginModelo(
        status: false,
        mensagem: 'Erro de conexão: $e',
      );
    }
  }

  static Future<Map<String, dynamic>> enviarOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$urlBase/enviar-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {
        'status': false,
        'mensagem': 'Erro ao enviar OTP: ${response.statusCode}',
      };
    } catch (e) {
      return {'status': false, 'mensagem': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> verificarOtp({
    required String email,
    required String codigo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$urlBase/verificar-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'codigo': codigo}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'status': false, 'mensagem': 'Código OTP inválido'};
    } catch (e) {
      return {'status': false, 'mensagem': 'Erro de conexão: $e'};
    }
  }
}
