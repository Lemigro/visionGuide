import 'package:flutter/material.dart';
import '../widgets/perfil/cartao_opcao.dart';
import '../widgets/perfil/modal_sobre.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/autenticacao_view_model.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perfil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF252A4D),
                      border: Border.all(
                        color: const Color(0xFF7C5CFF),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF7C5CFF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vladimir Nepomuceno',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'vladimir@email.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF7C5CFF),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Editar informação'),
              ),
            ),
            const SizedBox(height: 32),
            CartaoOpcao(
              titulo: 'Conta e Segurança',
              icone: Icons.security_outlined,
              aoTocar: () {},
            ),
            const SizedBox(height: 12),
            CartaoOpcao(
              titulo: 'Definições de permissões backend',
              icone: Icons.settings_outlined,
              aoTocar: () {
                context.push('/permissoes-backend');
              },
            ),
            const SizedBox(height: 12),
            CartaoOpcao(
              titulo: 'Sobre',
              icone: Icons.info_outlined,
              aoTocar: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: const Color(0xFF252A4D),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => const ModalSobre(),
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF252A4D),
                      title: const Text('Desconectar?'),
                      content: const Text(
                        'Tem certeza que deseja sair da sua conta?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<AutenticacaoViewModel>(
                              context,
                              listen: false,
                            ).desconectar();
                            Navigator.pop(context);
                            context.go('/entrar');
                          },
                          child: const Text(
                            'Sair',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Desconectar'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
