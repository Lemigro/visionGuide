import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        ChangeNotifierProvider(
          create: (_) => AutenticacaoViewModel()..inicializar(),
        ),
      ],
      child: const _AppComAcessibilidade(),
    ),
  );
}

class _AppComAcessibilidade extends StatelessWidget {
  const _AppComAcessibilidade();

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AcessibilidadeViewModel>();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(a11y.escalaFonte),
        boldText: a11y.altoContraste,
      ),
      child: const VisionGuideApp(),
    );
  }
}

class VisionGuideApp extends StatefulWidget {
  const VisionGuideApp({super.key});

  @override
  State<VisionGuideApp> createState() => _VisionGuideAppState();
}

class _VisionGuideAppState extends State<VisionGuideApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= criarRotasApp(context.read<AutenticacaoViewModel>());
  }

  @override
  Widget build(BuildContext context) {
    final router = _router;
    if (router == null) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF08111F),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final a11y = context.watch<AcessibilidadeViewModel>();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF63A7FF),
      brightness: Brightness.dark,
      contrastLevel: a11y.altoContraste ? 1.0 : 0.0,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'VisionGuide Mobile',
      routerConfig: router,
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
