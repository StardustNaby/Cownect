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
  // Usar manejo de errores robusto para evitar que la app se bloquee
  try {
    // Verificar si Firebase ya está inicializado
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e, stackTrace) {
    // Si hay un error de inicialización, registrar información útil
    // pero NO bloquear la app - permitir que cargue y muestre el error en la UI
    debugPrint('⚠️ Error al inicializar Firebase: $e');
    debugPrint('Stack trace: $stackTrace');
    debugPrint(
      '💡 Para Windows, asegúrate de haber registrado tu app en Firebase Console '
      'y obtenido el App ID correcto. Ejecuta: flutterfire configure --platforms=windows',
    );
    // NO re-lanzar el error - permitir que la app continúe
    // El router manejará la navegación y mostrará errores apropiados
  }

  // Ejecutar la app incluso si Firebase falló
  // El router y los providers manejarán los errores de forma elegante
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
    // Usar addPostFrameCallback para evitar bloqueos durante la inicialización
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificar autenticación de forma asíncrona sin bloquear la UI
      Future.microtask(() async {
        try {
          await ref.read(authNotifierProvider.notifier).checkAuth();
        } catch (e) {
          // Si hay error al verificar autenticación, no bloquear la app
          // El estado se establecerá como Unauthenticated automáticamente
          debugPrint('⚠️ Error al verificar autenticación: $e');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener temas desde los providers
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Obtener el router con redirect dinámico basado en autenticación
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Cownect',
      debugShowCheckedModeBanner: false,
      // Tema claro (optimizado para campo bajo sol directo)
      theme: lightTheme,
      // Tema oscuro (optimizado para oficina/casa)
      darkTheme: darkTheme,
      // Usar el modo de tema desde el provider
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

