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

  factory RespostaLoginModelo.fromJson(Map<String, dynamic> json) {
    final usuarioRaw = json['usuario'];
    Map<String, dynamic>? usuario;
    if (usuarioRaw is Map<String, dynamic>) {
      usuario = Map<String, dynamic>.from(usuarioRaw);
      if (usuario['id'] != null) {
        usuario['id'] = usuario['id'].toString();
      }
    }

    return RespostaLoginModelo(
      status: json['status'] as bool? ?? false,
      mensagem: json['mensagem'] as String? ?? '',
      token: json['token'] as String?,
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
