import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../dados/conteudo_inicio.dart';
import '../viewmodels/acessibilidade_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/home/aba_camera.dart';
import '../widgets/home/aba_chat.dart';
import '../widgets/home/aba_galeria.dart';
import '../widgets/home/aba_inicio.dart';
import '../widgets/home/aba_perfil.dart';
import '../widgets/home/cabecalho_app.dart';

class VisionGuideHome extends StatelessWidget {
  const VisionGuideHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(
        acessibilidade: context.read<AcessibilidadeViewModel>(),
      )..inicializar(),
      child: const VisionGuideHomeView(),
    );
  }
}

class VisionGuideHomeView extends StatefulWidget {
  const VisionGuideHomeView({super.key});

  @override
  State<VisionGuideHomeView> createState() => VisionGuideHomeViewState();
}

class VisionGuideHomeViewState extends State<VisionGuideHomeView> {
  final controladorChat = TextEditingController();
  final controladorRolagem = ScrollController();
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HomeViewModel>();
    _viewModel.addListener(_aoAtualizarViewModel);
  }

  void _aoAtualizarViewModel() {
    final vm = _viewModel;
    if (!vm.solicitarRolagem) return;
    vm.marcarRolagemConcluida();
    _rolarParaFinal();
  }

  void _rolarParaFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controladorRolagem.hasClients) {
        controladorRolagem.animateTo(
          controladorRolagem.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_aoAtualizarViewModel);
    controladorChat.dispose();
    controladorRolagem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    final pages = <Widget>[
      AbaInicio(
        key: const ValueKey('home-tab'),
        atalhos: ConteudoInicio.atalhosRapidos,
        aoAbrirCamera: vm.abrirCamera,
        aoAbrirChat: vm.abrirChat,
        aoAbrirGaleria: vm.abrirGaleria,
      ),
      AbaCamera(
        key: const ValueKey('camera'),
        aoCapturarEEnviar: () => _capturarImagem(context),
        aoAnalisar: () => _capturarImagem(context),
        aoModoContinuo: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Modo contínuo será ativado na próxima versão.'),
            ),
          );
        },
      ),
      AbaChat(
        key: const ValueKey('chat'),
        mensagens: vm.mensagens,
        controlador: controladorChat,
        controladorRolagem: controladorRolagem,
        aguardandoResposta: vm.aguardandoResposta,
        abaAtiva: vm.indiceAba == 2,
        aoEnviar: () {
          vm.enviarMensagem(controladorChat.text);
          controladorChat.clear();
        },
        aoEnviarTextoVoz: (texto) {
          vm.enviarMensagem(texto);
          controladorChat.clear();
        },
        aoEnviarImagem: () => _enviarImagemChat(context),
        aoLerMensagem: (texto) {
          context.read<AcessibilidadeViewModel>().lerTextoManual(texto);
        },
      ),
      AbaGaleria(
        key: const ValueKey('gallery'),
        itens: ConteudoInicio.itensGaleria,
      ),
      const AbaPerfil(key: ValueKey('profile')),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF08111F), Color(0xFF0D1730), Color(0xFF07101B)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                CabecalhoApp(
                  subtitulo: 'Visão computacional e realidade aumentada',
                  etiqueta: vm.etiquetaAba,
                ),
                Expanded(
                  child: IndexedStack(
                    index: vm.indiceAba,
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: vm.indiceAba,
          onDestinationSelected: vm.definirAba,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Início',
              tooltip: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.center_focus_strong_outlined),
              selectedIcon: Icon(Icons.center_focus_strong_rounded),
              label: 'Câmera',
              tooltip: 'Câmera assistiva para descrever ambiente',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'IA',
              tooltip: 'Assistente visual com voz e chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library_rounded),
              label: 'Galeria',
              tooltip: 'Galeria de fotos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
              tooltip: 'Perfil e configurações',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturarImagem(BuildContext context) async {
    final vm = context.read<HomeViewModel>();
    final erro = await vm.capturarEAnalisarImagem();
    if (!context.mounted) return;
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
    }
  }

  Future<void> _enviarImagemChat(BuildContext context) async {
    final vm = context.read<HomeViewModel>();
    final erro = await vm.enviarImagemDaGaleria();
    if (!context.mounted) return;
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
    }
  }
}
