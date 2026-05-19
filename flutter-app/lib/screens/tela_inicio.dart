import 'package:flutter/material.dart';
import 'tela_perfil.dart';
import '../widgets/inicio/conteudo_tela_inicio.dart';
import '../widgets/inicio/galeria_tela_inicio.dart';

class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key});

  @override
  State<TelaInicio> createState() => TelaInicioState();
}

class TelaInicioState extends State<TelaInicio> {
  int indiceAbaSelecionada = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161342),
      body: IndexedStack(
        index: indiceAbaSelecionada,
        children: const [
          ConteudoTelaInicio(),
          GaleriaTelaInicio(),
          TelaPerfil(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: indiceAbaSelecionada,
        onDestinationSelected: (indice) {
          setState(() => indiceAbaSelecionada = indice);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Galeria',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
