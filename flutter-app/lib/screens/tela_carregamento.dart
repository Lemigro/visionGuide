import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/logo_vision_guide.dart';

class TelaCarregamento extends StatefulWidget {
  const TelaCarregamento({super.key});

  @override
  State<TelaCarregamento> createState() => TelaCarregamentoState();
}

class TelaCarregamentoState extends State<TelaCarregamento> {
  @override
  void initState() {
    super.initState();
    _naveguarAposDelai();
  }

  void _naveguarAposDelai() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/entrar');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF08111F), Color(0xFF0D1730), Color(0xFF161342)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LogoVisionGuide(
                  largura: 240,
                  tagline: 'Visão computacional e navegação assistiva',
                  corTagline: const Color(0xFF9EA9C2),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF63A7FF)),
                  strokeWidth: 2.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
