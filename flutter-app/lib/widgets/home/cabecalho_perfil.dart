import 'package:flutter/material.dart';

class CabecalhoPerfil extends StatelessWidget {
  const CabecalhoPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17253C), Color(0xFF0F1727)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Row(
        children: [
          AvatarPerfil(),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perfil',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'Preferências de voz, alertas e resposta rápida.',
                  style: TextStyle(color: Color(0xFF9EA9C2), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarPerfil extends StatelessWidget {
  const AvatarPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x1A63A7FF),
        border: Border.all(color: Color(0x3363A7FF)),
      ),
      child: const Icon(Icons.person_rounded, size: 34, color: Colors.white),
    );
  }
}
