import 'package:flutter/material.dart';

import '../perfil/painel_acessibilidade.dart';

/// Atalho do painel completo, em modo compacto, na aba de chat.
class PainelAcessibilidadeChat extends StatelessWidget {
  const PainelAcessibilidadeChat({super.key});

  @override
  Widget build(BuildContext context) {
    return const PainelAcessibilidade(modoCompacto: true);
  }
}
