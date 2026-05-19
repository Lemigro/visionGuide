import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repositories/repositorio_autenticacao.dart';

class RegistroViewModel extends ChangeNotifier {
  RegistroViewModel({RepositorioAutenticacao? repositorio})
      : _repositorio = repositorio ?? RepositorioAutenticacao();

  final RepositorioAutenticacao _repositorio;

  int segundosRestantes = 0;
  bool otpEnviado = false;
  bool estaEnviandoOtp = false;
  String? mensagemOtp;

  Timer? _timerOtp;

  String formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '$minutos:${segs.toString().padLeft(2, '0')}';
  }

  Future<String?> enviarOtp(String email) async {
    if (email.isEmpty) {
      return 'Por favor, insira seu e-mail primeiro';
    }

    estaEnviandoOtp = true;
    mensagemOtp = null;
    notifyListeners();

    final resultado = await _repositorio.enviarOtp(email);

    estaEnviandoOtp = false;

    if (resultado['status'] == true) {
      otpEnviado = true;
      segundosRestantes = 130;
      _iniciarTimerOtp();
      notifyListeners();
      return null;
    }

    mensagemOtp = resultado['mensagem']?.toString() ?? 'Erro ao enviar OTP';
    notifyListeners();
    return mensagemOtp;
  }

  void _iniciarTimerOtp() {
    _timerOtp?.cancel();
    _timerOtp = Timer.periodic(const Duration(seconds: 1), (timer) {
      segundosRestantes--;
      if (segundosRestantes <= 0) {
        timer.cancel();
        otpEnviado = false;
        segundosRestantes = 0;
        mensagemOtp = 'Código OTP expirou. Solicite um novo.';
      }
      notifyListeners();
    });
  }

  Future<String?> verificarOtp({
    required String email,
    required String codigo,
  }) async {
    if (codigo.isEmpty) {
      return 'Por favor, insira o código OTP';
    }

    final verificacao = await _repositorio.verificarOtp(
      email: email,
      codigo: codigo,
    );

    if (verificacao['status'] != true) {
      return verificacao['mensagem']?.toString() ?? 'OTP inválido';
    }
    return null;
  }

  void limparMensagemOtp() {
    mensagemOtp = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timerOtp?.cancel();
    super.dispose();
  }
}
