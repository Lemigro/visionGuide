class RespostaLoginModelo {
  final bool status;
  final String mensagem;
  final String? token;
  final Map<String, dynamic>? usuario;

  RespostaLoginModelo({
    required this.status,
    required this.mensagem,
    this.token,
    this.usuario,
  });

  bool get sucesso => status && (token?.isNotEmpty ?? false);

  static bool _lerStatus(dynamic valor) {
    if (valor is bool) return valor;
    if (valor is num) return valor != 0;
    if (valor is String) {
      final v = valor.toLowerCase();
      return v == 'true' || v == '1';
    }
    return false;
  }

  factory RespostaLoginModelo.fromJson(Map<String, dynamic> json) {
    final usuarioRaw = json['usuario'];
    Map<String, dynamic>? usuario;
    if (usuarioRaw is Map) {
      usuario = Map<String, dynamic>.from(usuarioRaw);
      if (usuario['id'] != null) {
        usuario['id'] = usuario['id'].toString();
      }
    }

    return RespostaLoginModelo(
      status: _lerStatus(json['status']),
      mensagem: json['mensagem']?.toString() ?? '',
      token: json['token']?.toString(),
      usuario: usuario,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagem': mensagem,
      'token': token,
      'usuario': usuario,
    };
  }
}
