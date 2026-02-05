import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con las opciones de la plataforma actual
  try {
    // Verificar si Firebase ya está inicializado
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Si hay un error de inicialización, mostrar información útil
    debugPrint('Error al inicializar Firebase: $e');
    debugPrint(
      'Para Windows, asegúrate de haber registrado tu app en Firebase Console '
      'y obtenido el App ID correcto. Ejecuta: flutterfire configure --platforms=windows',
    );
    // Re-lanzar el error para que sea visible
    rethrow;
  }

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

