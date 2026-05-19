import 'package:flutter/material.dart';

class CartaoHero extends StatelessWidget {
  const CartaoHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF17253C), Color(0xFF0F1727), Color(0xFF08111F)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VISIONGUIDE',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF7FB2FF),
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Assistente Visual',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -0.6,
                ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Navegação e leitura inteligente em tempo real.',
            style: TextStyle(color: Color(0xFF9EA9C2), height: 1.4),
          ),
        ],
      ),
    );
  }
}
