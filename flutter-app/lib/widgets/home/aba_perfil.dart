import 'package:flutter/material.dart';

import '../perfil/painel_acessibilidade.dart';
import 'cabecalho_perfil.dart';

class AbaPerfil extends StatelessWidget {
  const AbaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const CabecalhoPerfil(),
        const SizedBox(height: 20),
        const PainelAcessibilidade(),
      ],
    );
  }
}
