import 'package:flutter/foundation.dart';

import '../models/usuario_modelo.dart';
import '../repositories/repositorio_autenticacao.dart';

class AutenticacaoViewModel extends ChangeNotifier {
  AutenticacaoViewModel({RepositorioAutenticacao? repositorio})
      : _repositorio = repositorio ?? RepositorioAutenticacao();

  final RepositorioAutenticacao _repositorio;

  UsuarioModelo? _usuarioAtual;
  String? _tokenJwt;
  bool _estaCarregando = false;
  String? _mensagemErro;
  bool _estaAutenticado = false;

  UsuarioModelo? get usuarioAtual => _usuarioAtual;
  String? get tokenJwt => _tokenJwt;
  bool get estaCarregando => _estaCarregando;
  String? get mensagemErro => _mensagemErro;
  bool get estaAutenticado => _estaAutenticado;

  Future<bool> realizarLogin(String email, String senha) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final resposta = await _repositorio.login(email, senha);

      if (resposta.status && resposta.token != null) {
        _tokenJwt = resposta.token;
        _estaAutenticado = true;
        _usuarioAtual = UsuarioModelo(
          id: resposta.usuario?['id']?.toString() ?? '',
          nome: resposta.usuario?['nome']?.toString() ?? '',
          email: resposta.usuario?['email']?.toString() ?? '',
          fotoPerfil: resposta.usuario?['fotoPerfil']?.toString(),
          dataCadastro: DateTime.now(),
        );
        _estaCarregando = false;
        notifyListeners();
        return true;
      }

      _mensagemErro = resposta.mensagem;
      _estaCarregando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _mensagemErro = 'Erro ao fazer login: $e';
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrarUsuario({
    required String email,
    required String nome,
    required String senha,
    required String confirmacaoSenha,
    required String codigoOtp,
  }) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final resposta = await _repositorio.registrar(
        email: email,
        nome: nome,
        senha: senha,
        confirmacaoSenha: confirmacaoSenha,
        codigoOtp: codigoOtp,
      );

      if (resposta.status) {
        _tokenJwt = resposta.token;
        _estaAutenticado = true;
        _estaCarregando = false;
        notifyListeners();
        return true;
      }

      _mensagemErro = resposta.mensagem;
      _estaCarregando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _mensagemErro = 'Erro ao registrar: $e';
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  void desconectar() {
    _usuarioAtual = null;
    _tokenJwt = null;
    _estaAutenticado = false;
    _mensagemErro = null;
    notifyListeners();
  }
}
