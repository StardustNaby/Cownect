import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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
import '../../presentation/screens/ajustes_screen.dart';
import '../../presentation/screens/perfil_screen.dart';
import '../../presentation/screens/bovino_detail_screen.dart';
import '../../presentation/screens/error_screen.dart';
import '../../presentation/screens/main_scaffold.dart';
import '../../presentation/providers/auth_provider.dart';

/// ChangeNotifier que escucha cambios en el estado de autenticación
/// y notifica a GoRouter para que actualice las redirecciones.
class _AuthStateNotifier extends ChangeNotifier {
  final Ref _ref;
  AuthState? _previousState;
  late final ProviderSubscription<AuthState> _subscription;

  _AuthStateNotifier(this._ref) {
    // Inicializar el estado de forma segura
    try {
      _previousState = _ref.read(authNotifierProvider);
    } catch (e) {
      // Si hay error al leer (por ejemplo, SharedPreferences no está listo),
      // establecer estado inicial como Loading
      _previousState = null;
    }
    
    // Escuchar cambios en el estado de autenticación
    _subscription = _ref.listen(
      authNotifierProvider,
      (previous, next) {
        if (_previousState != next) {
          _previousState = next;
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }

  /// Obtiene el estado actual de autenticación
  /// Retorna Loading si hay algún error al leer el estado
  AuthState get currentState {
    try {
      return _ref.read(authNotifierProvider);
    } catch (e) {
      // Si hay error (por ejemplo, SharedPreferences no está listo),
      // retornar Loading para permitir que la app continúe
      return Loading();
    }
  }
}

/// Provider que expone el GoRouter con redirect dinámico basado en autenticación.
/// 
/// El router escucha cambios en el estado de autenticación y redirige automáticamente:
/// - Si el usuario está autenticado y está en /login o /register, redirige a /predios
/// - Si el usuario no está autenticado y está en rutas protegidas, redirige a /login
/// - Permite navegación libre entre /login y /register sin bloqueos
final appRouterProvider = Provider<GoRouter>((ref) {
  // Crear el ChangeNotifier que escucha cambios en autenticación
  final authNotifier = _AuthStateNotifier(ref);
  
  return GoRouter(
    initialLocation: '/login',
    // Redirect dinámico basado en el estado de autenticación
    redirect: (context, state) {
      final authState = authNotifier.currentState;
      final isAuthenticated = authState is Authenticated;
      final isLoading = authState is Loading;
      final isUnauthenticated = authState is Unauthenticated;
      
      final isLoginRoute = state.uri.path == '/login';
      final isRegisterRoute = state.uri.path == '/register';
      final isColaboradorRoute = state.uri.path == '/colaborador';
      final isAuthRoute = isLoginRoute || isRegisterRoute || isColaboradorRoute;
      
      // Rutas públicas (siempre accesibles)
      if (isAuthRoute) {
        // Si está autenticado y está en login/register, redirigir a predios
        if (isAuthenticated) {
          return '/predios';
        }
        // Si no está autenticado o está cargando, permitir acceso a login/register
        return null; // Permitir acceso
      }
      
      // Rutas protegidas (requieren autenticación)
      // Si está cargando, no redirigir (evitar loops y permitir navegación manual)
      if (isLoading) {
        return null; // Esperar a que termine la carga, pero permitir navegación
      }
      
      // Si no está autenticado y está en una ruta protegida, redirigir a login
      if (isUnauthenticated) {
        return '/login';
      }
      
      // Si está autenticado, permitir acceso a todas las rutas
      return null;
    },
    // Refresh cuando cambie el estado de autenticación
    refreshListenable: authNotifier,
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

    // Ruta de Perfil
    GoRoute(
      path: '/perfil',
      name: 'perfil',
      builder: (context, state) => const PerfilScreen(),
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
              builder: (context, state) {
                // Obtener predioId de query parameters si está presente
                final predioId = state.uri.queryParameters['predioId'];
                return InicioScreen(predioId: predioId);
              },
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
              builder: (context, state) {
                // Obtener predioId de query parameters si está presente
                final predioId = state.uri.queryParameters['predioId'];
                return AnimalesScreen(predioId: predioId);
              },
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
});

/// Router legacy para compatibilidad (usar appRouterProvider en su lugar).
/// 
/// @deprecated Usa appRouterProvider en su lugar para obtener el router
/// con redirect dinámico basado en autenticación.
@Deprecated('Usa appRouterProvider en su lugar')
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  errorBuilder: (context, state) => ErrorScreen(
    error: state.error?.toString(),
    path: state.uri.path,
  ),
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/colaborador',
      name: 'colaborador',
      builder: (context, state) => const ColaboradorScreen(),
    ),
    GoRoute(
      path: '/predios',
      name: 'predios',
      builder: (context, state) => const PrediosHomeScreen(),
    ),
    GoRoute(
      path: '/predio/registro',
      name: 'registro-predio',
      builder: (context, state) => const RegistroPredioScreen(),
    ),
    GoRoute(
      path: '/ajustes',
      name: 'ajustes',
      builder: (context, state) => const AjustesScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/predio/home',
              name: 'predio-inicio',
              builder: (context, state) => const InicioScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/predio/sectores',
              name: 'predio-sectores',
              builder: (context, state) => const SectoresScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/predio/animales',
              name: 'predio-animales',
              builder: (context, state) => const AnimalesScreen(),
            ),
          ],
        ),
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

