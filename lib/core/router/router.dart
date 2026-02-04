import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/colaborador_screen.dart';
import '../../presentation/screens/predios/predios_home_screen.dart';
import '../../presentation/screens/predios/registro_predio_screen.dart';
import '../../presentation/screens/predio/inicio_screen.dart';
import '../../presentation/screens/predio/sectores_screen.dart';
import '../../presentation/screens/predio/animales_screen.dart';
import '../../presentation/screens/predio/colaboradores_screen.dart';
import '../../presentation/screens/inventory/inventory_screen.dart';
import '../../presentation/screens/infraestructura_screen.dart';
import '../../presentation/screens/perfil_screen.dart';
import '../../presentation/screens/ajustes_screen.dart';
import '../../presentation/screens/bovino_detail_screen.dart';
import '../../presentation/screens/error_screen.dart';
import '../../presentation/screens/main_scaffold.dart';

/// Configuración de rutas de la aplicación usando go_router.
/// 
/// Estructura:
/// - Ruta raíz: /login (pantalla de acceso)
/// - StatefulShellRoute con NavigationShell: Inventario, Infraestructura, Perfil
/// - Ruta de detalle: /bovino/:id (con Hero Animation)
/// - Manejo de errores 404
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  errorBuilder: (context, state) => ErrorScreen(
    error: state.error?.toString(),
    path: state.uri.path,
  ),
  routes: [
    // Ruta de Login (raíz)
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Ruta de Registro
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Ruta de Colaborador
    GoRoute(
      path: '/colaborador',
      name: 'colaborador',
      builder: (context, state) => const ColaboradorScreen(),
    ),

    // Ruta de Predios Home (pantalla inicial después del login)
    GoRoute(
      path: '/predios',
      name: 'predios',
      builder: (context, state) => const PrediosHomeScreen(),
    ),

    // Ruta de Registro de Predio
    GoRoute(
      path: '/predio/registro',
      name: 'registro-predio',
      builder: (context, state) => const RegistroPredioScreen(),
    ),

    // Ruta de Ajustes
    GoRoute(
      path: '/ajustes',
      name: 'ajustes',
      builder: (context, state) => const AjustesScreen(),
    ),

    // StatefulShellRoute con navegación por tabs usando NavigationShell
    // Esta es la navegación dentro de un predio
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Inicio
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/predio/home',
              name: 'predio-inicio',
              builder: (context, state) => const InicioScreen(),
            ),
          ],
        ),
        // Branch 1: Sectores
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/predio/sectores',
              name: 'predio-sectores',
              builder: (context, state) => const SectoresScreen(),
            ),
          ],
        ),
        // Branch 2: Animales
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/predio/animales',
              name: 'predio-animales',
              builder: (context, state) => const AnimalesScreen(),
            ),
          ],
        ),
        // Branch 3: Colaboradores
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/predio/colaboradores',
              name: 'predio-colaboradores',
              builder: (context, state) => const ColaboradoresScreen(),
            ),
          ],
        ),
      ],
    ),

    // Rutas legacy (mantener para compatibilidad)
    GoRoute(
      path: '/inventario',
      name: 'inventario',
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(
      path: '/infraestructura',
      name: 'infraestructura',
      builder: (context, state) => const InfraestructuraScreen(),
    ),

    // Ruta de detalle de bovino (fuera del shell para pantalla completa)
    // Incluye Hero Animation para la transición
    GoRoute(
      path: '/bovino/:id',
      name: 'bovino-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BovinoDetailScreen(bovinoId: id);
      },
    ),
  ],
);


