import 'package:flutter/material.dart';

import 'cabecalho_perfil.dart';
import 'linha_configuracao.dart';

class AbaPerfil extends StatelessWidget {
  const AbaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: const [
        CabecalhoPerfil(),
        SizedBox(height: 14),
        LinhaConfiguracao(titulo: 'Voz', valor: 'PT-BR'),
        SizedBox(height: 10),
        LinhaConfiguracao(titulo: 'Velocidade', valor: 'Normal'),
        SizedBox(height: 10),
        LinhaConfiguracao(titulo: 'Alertas', valor: 'Ativos'),
        SizedBox(height: 10),
        LinhaConfiguracao(titulo: 'Tema', valor: 'Escuro'),
      ],
    );
  }
}
