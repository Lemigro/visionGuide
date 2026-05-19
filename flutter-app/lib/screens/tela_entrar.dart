import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/config_backend.dart';
import '../widgets/campo_texto_customizado.dart';
import '../widgets/botao_primario.dart';
import '../viewmodels/autenticacao_view_model.dart';
import '../widgets/logo_vision_guide.dart';

class TelaEntrar extends StatefulWidget {
  const TelaEntrar({super.key});

  @override
  State<TelaEntrar> createState() => TelaEntrarState();
}

class TelaEntrarState extends State<TelaEntrar> {
  final _formularioChave = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: 'teste@visionguide.com',
  );
  final _senhaController = TextEditingController(text: '123456');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AutenticacaoViewModel>().verificarServidor();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _aposLoginOk(AutenticacaoViewModel auth) async {
    if (!mounted || !auth.estaAutenticado) return;
    context.go('/inicio');
  }

  Future<void> _fazerLogin() async {
    if (!_formularioChave.currentState!.validate()) return;

    final auth = context.read<AutenticacaoViewModel>();

    final sucesso = await auth.realizarLogin(
      _emailController.text,
      _senhaController.text,
    );

    if (!mounted) return;

    if (sucesso) {
      await _aposLoginOk(auth);
    }
  }

  Future<void> _entrarContaTeste() async {
    final auth = context.read<AutenticacaoViewModel>();
    _emailController.text = 'teste@visionguide.com';
    _senhaController.text = '123456';

    final sucesso = await auth.entrarComContaTeste();
    if (!mounted) return;
    if (sucesso) {
      await _aposLoginOk(auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161342),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            const LogoVisionGuide(
              largura: 160,
              tagline: 'Fazer login em sua conta',
            ),
            const SizedBox(height: 40),
            Form(
              key: _formularioChave,
              child: Column(
                children: [
                  CampoTextoCustomizado(
                    label: 'E-mail',
                    dica: 'seu@email.com',
                    controller: _emailController,
                    icone: Icons.email_outlined,
                    validador: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu e-mail';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CampoTextoCustomizado(
                    label: 'Senha',
                    dica: 'Digite sua senha',
                    controller: _senhaController,
                    esSenha: true,
                    icone: Icons.lock_outlined,
                    validador: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Consumer<AutenticacaoViewModel>(
              builder: (context, auth, _) {
                final online = auth.servidorOnline;
                final corServidor = online == true
                    ? const Color(0xFF7AD089)
                    : online == false
                        ? const Color(0xFFE57373)
                        : const Color(0xFF9EA9C2);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0x141F2A3D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            online == true
                                ? 'Servidor online'
                                : online == false
                                    ? 'Servidor offline — rode: python main.py'
                                    : 'Verificando servidor…',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: corServidor, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ConfigBackend.urlAuth,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9EA9C2),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (auth.mensagemErro != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0x33E53935),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          auth.mensagemErro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFCDD2),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    BotaoPrimario(
                      texto: 'Entrar',
                      aoClicar: _fazerLogin,
                      estaCarregando: auth.estaCarregando,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed:
                          auth.estaCarregando ? null : _entrarContaTeste,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Entrar com conta teste'),
                    ),
                    TextButton(
                      onPressed: auth.estaCarregando
                          ? null
                          : () => auth.verificarServidor(),
                      child: const Text('Testar conexão com servidor'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Divider(
                    color: Color(0xFF424242),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Não tem cadastro?',
                    style: TextStyle(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(
                    color: Color(0xFF424242),
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.push('/registrar'),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Criar conta',
                      style: TextStyle(
                        color: Color(0xFF7C5CFF),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(
                    color: Color(0xFF424242),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset('assets/images/google.png'),
                ),
                label: const Text('Entrar com o Google'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
