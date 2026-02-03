import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/inventory/inventory_screen.dart';
import '../../presentation/screens/infraestructura_screen.dart';
import '../../presentation/screens/perfil_screen.dart';
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

    // StatefulShellRoute con navegación por tabs usando NavigationShell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Inventario
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inventario',
              name: 'inventario',
              builder: (context, state) => const InventoryScreen(),
            ),
          ],
        ),
        // Branch 1: Infraestructura
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/infraestructura',
              name: 'infraestructura',
              builder: (context, state) => const InfraestructuraScreen(),
            ),
          ],
        ),
        // Branch 2: Perfil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/perfil',
              name: 'perfil',
              builder: (context, state) => const PerfilScreen(),
            ),
          ],
        ),
      ],
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


