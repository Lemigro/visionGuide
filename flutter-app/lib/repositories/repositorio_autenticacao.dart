import '../models/resposta_login_modelo.dart';
import 'api_autenticacao.dart';

class RepositorioAutenticacao {
  Future<RespostaLoginModelo> login(String email, String senha) {
    return ApiAutenticacao.realizarLogin(email, senha);
  }

  Future<RespostaLoginModelo> registrar({
    required String email,
    required String nome,
    required String senha,
    required String confirmacaoSenha,
    required String codigoOtp,
  }) {
    return ApiAutenticacao.registrarUsuario(
      email: email,
      nome: nome,
      senha: senha,
      confirmacaoSenha: confirmacaoSenha,
      codigoOtp: codigoOtp,
    );
  }

  Future<Map<String, dynamic>> enviarOtp(String email) {
    return ApiAutenticacao.enviarOtp(email);
  }

  Future<Map<String, dynamic>> verificarOtp({
    required String email,
    required String codigo,
  }) {
    return ApiAutenticacao.verificarOtp(email: email, codigo: codigo);
  }
}
