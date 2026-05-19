import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/rotas.dart';
import 'viewmodels/acessibilidade_view_model.dart';
import 'viewmodels/autenticacao_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AcessibilidadeViewModel()..inicializar(),
        ),
        ChangeNotifierProvider(create: (_) => AutenticacaoViewModel()),
      ],
      child: const VisionGuideApp(),
    ),
  );
}

class VisionGuideApp extends StatelessWidget {
  const VisionGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF63A7FF),
      brightness: Brightness.dark,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'VisionGuide Mobile',
      routerConfig: rotasApp(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF08111F),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xF208111F),
          indicatorColor: const Color(0x2663A7FF),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            side: BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0x141F2A3D),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: const TextStyle(color: Color(0xFF8F9AB3)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
