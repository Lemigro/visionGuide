import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/campo_texto_customizado.dart';
import '../widgets/botao_primario.dart';
import '../viewmodels/autenticacao_view_model.dart';
import '../viewmodels/registro_view_model.dart';
import '../widgets/logo_vision_guide.dart';

class TelaRegistrar extends StatelessWidget {
  const TelaRegistrar({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistroViewModel(),
      child: const TelaRegistrarView(),
    );
  }
}

class TelaRegistrarView extends StatefulWidget {
  const TelaRegistrarView({super.key});

  @override
  State<TelaRegistrarView> createState() => TelaRegistrarViewState();
}

class TelaRegistrarViewState extends State<TelaRegistrarView> {
  final formularioChave = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final codigoOtpController = TextEditingController();
  final nomeController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmacaoSenhaController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    codigoOtpController.dispose();
    nomeController.dispose();
    senhaController.dispose();
    confirmacaoSenhaController.dispose();
    super.dispose();
  }

  Future<void> enviarOtp() async {
    final vm = context.read<RegistroViewModel>();
    final erro = await vm.enviarOtp(emailController.text);
    if (!mounted) return;

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código OTP enviado para seu e-mail'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> verificarOtpERegistrar() async {
    if (!formularioChave.currentState!.validate()) return;

    final registroVm = context.read<RegistroViewModel>();
    final autenticacaoVm =
        Provider.of<AutenticacaoViewModel>(context, listen: false);

    final erroOtp = await registroVm.verificarOtp(
      email: emailController.text,
      codigo: codigoOtpController.text,
    );

    if (!mounted) return;
    if (erroOtp != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erroOtp), backgroundColor: Colors.red),
      );
      return;
    }

    if (senhaController.text != confirmacaoSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sucesso = await autenticacaoVm.registrarUsuario(
      email: emailController.text,
      nome: nomeController.text,
      senha: senhaController.text,
      confirmacaoSenha: confirmacaoSenhaController.text,
      codigoOtp: codigoOtpController.text,
    );

    if (!mounted) return;

    if (sucesso) {
      context.go('/inicio');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(autenticacaoVm.mensagemErro ?? 'Erro ao registrar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final registroVm = context.watch<RegistroViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF161342),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161342),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Registrar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formularioChave,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: LogoVisionGuide(
                  largura: 130,
                  tagline: 'Criar sua conta VisionGuide',
                ),
              ),
              const SizedBox(height: 28),
              CampoTextoCustomizado(
                label: 'E-mail',
                dica: 'seu@email.com',
                controller: emailController,
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
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CampoTextoCustomizado(
                      label: 'Código de verificação',
                      dica: '000000',
                      controller: codigoOtpController,
                      icone: Icons.lock_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: registroVm.otpEnviado ||
                                  registroVm.estaEnviandoOtp
                              ? null
                              : enviarOtp,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF7C5CFF),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 8,
                            ),
                          ),
                          child: registroVm.estaEnviandoOtp
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : registroVm.otpEnviado
                                  ? Text(
                                      registroVm.formatarTempo(
                                        registroVm.segundosRestantes,
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF7C5CFF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const Text('Enviar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CampoTextoCustomizado(
                label: 'Nome Utilizador',
                dica: 'Seu nome completo',
                controller: nomeController,
                icone: Icons.person_outline,
                validador: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  if (value.length < 3) {
                    return 'O nome deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CampoTextoCustomizado(
                label: 'Senha',
                dica: 'Digite uma senha forte',
                controller: senhaController,
                esSenha: true,
                icone: Icons.lock_outlined,
                validador: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CampoTextoCustomizado(
                label: 'Confirmar senha',
                dica: 'Confirme sua senha',
                controller: confirmacaoSenhaController,
                esSenha: true,
                icone: Icons.lock_outlined,
                validador: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme sua senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Consumer<AutenticacaoViewModel>(
                builder: (context, autenticacao, _) {
                  return BotaoPrimario(
                    texto: 'Confirmar',
                    aoClicar: verificarOtpERegistrar,
                    estaCarregando: autenticacao.estaCarregando,
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text(
                    'Já tem conta? Voltar para login',
                    style: TextStyle(
                      color: Color(0xFF7C5CFF),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
