import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: CownectApp(),
    ),
  );
}

class CownectApp extends ConsumerStatefulWidget {
  const CownectApp({super.key});

  @override
  ConsumerState<CownectApp> createState() => _CownectAppState();
}

class _CownectAppState extends ConsumerState<CownectApp> {
  @override
  void initState() {
    super.initState();
    // Verificar si hay una sesión activa al iniciar la app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener temas desde los providers
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Cownect',
      debugShowCheckedModeBanner: false,
      // Tema claro (optimizado para campo bajo sol directo)
      theme: lightTheme,
      // Tema oscuro (optimizado para oficina/casa)
      darkTheme: darkTheme,
      // Usar el modo de tema desde el provider
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}

