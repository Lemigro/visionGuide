import 'package:flutter/foundation.dart';

import '../core/config_backend.dart';
import '../models/resposta_login_modelo.dart';
import '../models/usuario_modelo.dart';
import '../repositories/api_autenticacao.dart';
import '../repositories/repositorio_autenticacao.dart';
import '../repositories/repositorio_sessao.dart';

class AutenticacaoViewModel extends ChangeNotifier {
  AutenticacaoViewModel({
    RepositorioAutenticacao? repositorio,
    RepositorioSessao? sessao,
  })  : _repositorio = repositorio ?? RepositorioAutenticacao(),
        _sessao = sessao ?? RepositorioSessao();

  final RepositorioAutenticacao _repositorio;
  final RepositorioSessao _sessao;

  UsuarioModelo? _usuarioAtual;
  String? _tokenJwt;
  bool _estaCarregando = false;
  String? _mensagemErro;
  bool _estaAutenticado = false;
  bool _sessaoVerificada = false;
  bool? _servidorOnline;

  UsuarioModelo? get usuarioAtual => _usuarioAtual;
  String? get tokenJwt => _tokenJwt;
  bool get estaCarregando => _estaCarregando;
  String? get mensagemErro => _mensagemErro;
  bool get estaAutenticado => _estaAutenticado;
  bool get sessaoVerificada => _sessaoVerificada;
  bool? get servidorOnline => _servidorOnline;

  Future<void> inicializar() async {
    try {
      final salva = await _sessao.carregar();
      if (salva != null) {
        _aplicarSessao(salva.token, salva.usuario);
      }
    } catch (e) {
      debugPrint('Erro ao restaurar sessão: $e');
    }
    _sessaoVerificada = true;
    notifyListeners();
    await verificarServidor();
  }

  void _aplicarSessao(String token, Map<String, dynamic> usuario) {
    _tokenJwt = token;
    _estaAutenticado = true;
    _usuarioAtual = UsuarioModelo(
      id: usuario['id']?.toString() ?? '',
      nome: usuario['nome']?.toString() ?? '',
      email: usuario['email']?.toString() ?? '',
      fotoPerfil: usuario['fotoPerfil']?.toString(),
      dataCadastro: DateTime.now(),
    );
  }

  void _aplicarRespostaLogin(RespostaLoginModelo resposta) {
    if (resposta.token == null || resposta.token!.isEmpty) {
      throw StateError('Token ausente na resposta do servidor');
    }
    _aplicarSessao(
      resposta.token!,
      resposta.usuario ?? {'email': '', 'nome': 'Usuário', 'id': '0'},
    );
  }

  Future<void> _persistirSessao() async {
    if (_tokenJwt == null || _usuarioAtual == null) return;
    try {
      await _sessao.salvar(
        token: _tokenJwt!,
        usuario: {
          'id': _usuarioAtual!.id,
          'nome': _usuarioAtual!.nome,
          'email': _usuarioAtual!.email,
          if (_usuarioAtual!.fotoPerfil != null)
            'fotoPerfil': _usuarioAtual!.fotoPerfil,
        },
      );
    } catch (e) {
      debugPrint('Aviso: não foi possível salvar sessão local: $e');
    }
  }

  Future<void> verificarServidor() async {
    _servidorOnline = await ApiAutenticacao.verificarServidor();
    notifyListeners();
  }

  Future<bool> realizarLogin(String email, String senha) async {
    _estaCarregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final resposta = await _repositorio.login(email, senha);

      if (resposta.sucesso) {
        _aplicarRespostaLogin(resposta);
        await _persistirSessao();
        _estaCarregando = false;
        _mensagemErro = null;
        notifyListeners();
        return true;
      }

      _mensagemErro = resposta.mensagem.isNotEmpty
          ? resposta.mensagem
          : 'Não foi possível entrar. Verifique e-mail e senha.';
      _servidorOnline = true;
      _estaCarregando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _mensagemErro = 'Erro ao fazer login: $e';
      _servidorOnline = false;
      _estaCarregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> entrarComContaTeste() {
    return realizarLogin('teste@visionguide.com', '123456');
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

      if (resposta.sucesso) {
        _aplicarRespostaLogin(resposta);
        await _persistirSessao();
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

  Future<void> desconectar() async {
    _usuarioAtual = null;
    _tokenJwt = null;
    _estaAutenticado = false;
    _mensagemErro = null;
    try {
      await _sessao.limpar();
    } catch (_) {}
    notifyListeners();
  }
}
