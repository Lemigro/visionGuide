import 'package:flutter/material.dart';

/// Logo oficial VisionGuide (ícone + wordmark).
class LogoVisionGuide extends StatelessWidget {
  const LogoVisionGuide({
    super.key,
    this.largura = 200,
    this.tagline,
    this.corTagline = const Color(0xFF9CA3AF),
  });

  static const String caminhoAsset = 'assets/images/logo.png';

  final double largura;
  final String? tagline;
  final Color corTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          caminhoAsset,
          width: largura,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.remove_red_eye_outlined,
              size: largura * 0.4,
              color: const Color(0xFF63A7FF),
            );
          },
        ),
        if (tagline != null) ...[
          const SizedBox(height: 12),
          Text(
            tagline!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: corTagline,
              fontSize: 16,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
