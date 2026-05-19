import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config_backend.dart';

class ResultadoAnaliseImagem {
  const ResultadoAnaliseImagem({
    required this.sucesso,
    required this.descricao,
  });

  final bool sucesso;
  final String descricao;
}

class RepositorioVisao {
  Future<ResultadoAnaliseImagem> analisarBase64(String base64Imagem) async {
    try {
      final response = await http.post(
        Uri.parse(ConfigBackend.urlAnalyze),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': 'data:image/jpeg;base64,$base64Imagem',
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final descricao = body['description'] as String? ??
            'Análise concluída, mas sem descrição retornada.';
        return ResultadoAnaliseImagem(sucesso: true, descricao: descricao);
      }

      return ResultadoAnaliseImagem(
        sucesso: false,
        descricao:
            'Não foi possível analisar a imagem (HTTP ${response.statusCode}).',
      );
    } catch (_) {
      return const ResultadoAnaliseImagem(
        sucesso: false,
        descricao:
            'Não consegui conectar ao servidor de análise. Confira se o backend está em execução na porta 3001.',
      );
    }
  }
}
