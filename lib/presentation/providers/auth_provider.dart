import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../core/providers/supabase_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estados posibles de autenticación.
sealed class AuthState {}

/// Estado cuando el usuario no está autenticado.
class Unauthenticated extends AuthState {
  @override
  String toString() => 'Unauthenticated';
}

/// Estado cuando se está verificando la sesión.
class Loading extends AuthState {
  @override
  String toString() => 'Loading';
}

/// Estado cuando el usuario está autenticado.
class Authenticated extends AuthState {
  final UsuarioEntity user;

  Authenticated(this.user);

  @override
  String toString() => 'Authenticated(user: ${user.nombreCompleto})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Authenticated && other.user.id == user.id;
  }

  @override
  int get hashCode => user.id.hashCode;
}

/// Notifier que gestiona el estado de autenticación.
/// 
/// Monitorea los cambios de sesión de Supabase y proporciona
/// métodos para login, logout y verificación de sesión.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SupabaseClient _supabaseClient;
  final SharedPreferences _prefs;

  // Clave para almacenar la preferencia de "mantener sesión"
  static const String _rememberMeKey = 'remember_me';
  static const String _userEmailKey = 'user_email';

  StreamSubscription? _authSubscription;

  AuthNotifier(
    this._authRepository,
    this._supabaseClient,
    this._prefs,
  ) : super(Loading()) {
    // Escuchar cambios en el estado de autenticación de Supabase
    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen(_handleAuthStateChange);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Maneja los cambios en el estado de autenticación de Supabase.
  Future<void> _handleAuthStateChange(dynamic authStateChange) async {
    // Usar reflexión para acceder a los eventos
    try {
      final event = authStateChange.event;
      if (event.toString().contains('signedIn') || 
          event.toString().contains('SIGNED_IN')) {
        // Usuario inició sesión
        await _loadUser();
      } else if (event.toString().contains('signedOut') || 
                 event.toString().contains('SIGNED_OUT')) {
        // Usuario cerró sesión
        state = Unauthenticated();
      } else if (event.toString().contains('tokenRefreshed') || 
                 event.toString().contains('TOKEN_REFRESHED')) {
        // Token refrescado, verificar usuario
        await _loadUser();
      }
    } catch (e) {
      // Si hay error, simplemente recargar el usuario
      await _loadUser();
    }
  }

  /// Carga el usuario actual desde el repositorio.
  Future<void> _loadUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = Unauthenticated();
      }
    } catch (e) {
      state = Unauthenticated();
    }
  }

  /// Verifica si hay una sesión activa al iniciar la app.
  /// 
  /// Esta función debe llamarse al iniciar la aplicación para
  /// verificar si el usuario ya tiene una sesión activa.
  Future<void> checkAuth() async {
    state = Loading();

    try {
      // Verificar si el usuario quiere mantener la sesión
      final rememberMe = _prefs.getBool(_rememberMeKey) ?? false;

      if (!rememberMe) {
        // Si no quiere mantener la sesión, cerrar sesión
        await _authRepository.signOut();
        state = Unauthenticated();
        return;
      }

      // Verificar si hay un usuario autenticado
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = Unauthenticated();
      }
    } catch (e) {
      state = Unauthenticated();
    }
  }

  /// Inicia sesión con correo electrónico y contraseña.
  /// 
  /// [email] - Correo electrónico del usuario
  /// [password] - Contraseña del usuario
  /// [rememberMe] - Si es true, mantiene la sesión iniciada en el dispositivo
  /// 
  /// Retorna el usuario autenticado o lanza una excepción.
  Future<UsuarioEntity> signInWithEmail({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = Loading();

    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      // Guardar preferencia de "mantener sesión"
      await _prefs.setBool(_rememberMeKey, rememberMe);
      if (rememberMe) {
        await _prefs.setString(_userEmailKey, email);
      } else {
        await _prefs.remove(_userEmailKey);
      }

      state = Authenticated(user);
      return user;
    } catch (e) {
      state = Unauthenticated();
      rethrow;
    }
  }

  /// Inicia sesión con código OTP por SMS.
  /// 
  /// [phone] - Número de teléfono del usuario
  /// [otp] - Código OTP recibido por SMS
  /// [rememberMe] - Si es true, mantiene la sesión iniciada en el dispositivo
  /// 
  /// Retorna el usuario autenticado o lanza una excepción.
  Future<UsuarioEntity> signInWithOTP({
    required String phone,
    required String otp,
    required bool rememberMe,
  }) async {
    state = Loading();

    try {
      final user = await _authRepository.signInWithOTP(
        phone: phone,
        otp: otp,
      );

      // Guardar preferencia de "mantener sesión"
      await _prefs.setBool(_rememberMeKey, rememberMe);
      if (rememberMe) {
        await _prefs.setString(_userEmailKey, phone);
      } else {
        await _prefs.remove(_userEmailKey);
      }

      state = Authenticated(user);
      return user;
    } catch (e) {
      state = Unauthenticated();
      rethrow;
    }
  }

  /// Registra un nuevo usuario.
  /// 
  /// [email] - Correo electrónico del nuevo usuario (opcional)
  /// [phone] - Teléfono del nuevo usuario (opcional)
  /// [password] - Contraseña del nuevo usuario
  /// [nombreCompleto] - Nombre completo del usuario
  /// [fechaNacimiento] - Fecha de nacimiento del usuario
  /// [rememberMe] - Si es true, mantiene la sesión iniciada en el dispositivo
  /// 
  /// Retorna el usuario registrado o lanza una excepción.
  Future<UsuarioEntity> signUp({
    String? email,
    String? phone,
    required String password,
    required String nombreCompleto,
    required DateTime fechaNacimiento,
    required bool rememberMe,
  }) async {
    state = Loading();

    try {
      final user = await _authRepository.signUp(
        email: email,
        phone: phone,
        password: password,
        nombreCompleto: nombreCompleto,
        fechaNacimiento: fechaNacimiento,
      );

      // Guardar preferencia de "mantener sesión"
      await _prefs.setBool(_rememberMeKey, rememberMe);
      if (rememberMe) {
        final identifier = email ?? phone ?? '';
        await _prefs.setString(_userEmailKey, identifier);
      } else {
        await _prefs.remove(_userEmailKey);
      }

      state = Authenticated(user);
      return user;
    } catch (e) {
      state = Unauthenticated();
      rethrow;
    }
  }

  /// Cierra la sesión del usuario actual.
  /// 
  /// También limpia las preferencias de "mantener sesión".
  Future<void> signOut() async {
    state = Loading();

    try {
      await _authRepository.signOut();

      // Limpiar preferencias
      await _prefs.remove(_rememberMeKey);
      await _prefs.remove(_userEmailKey);

      state = Unauthenticated();
    } catch (e) {
      // Incluso si hay error, establecer como no autenticado
      state = Unauthenticated();
      rethrow;
    }
  }

  /// Envía un código OTP por SMS.
  /// 
  /// [phone] - Número de teléfono al que se enviará el OTP
  Future<void> sendOTP({required String phone}) async {
    await _authRepository.sendOTP(phone: phone);
  }

  /// Obtiene el email guardado si existe (para "mantener sesión").
  String? getSavedEmail() {
    return _prefs.getString(_userEmailKey);
  }

  /// Verifica si el usuario quiere mantener la sesión.
  bool getRememberMe() {
    return _prefs.getBool(_rememberMeKey) ?? false;
  }
}

/// Provider que expone SharedPreferences para el AuthNotifier.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider que expone el AuthNotifier.
/// 
/// Este provider gestiona el estado de autenticación de la aplicación.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final supabaseClient = ref.watch(supabaseClientProvider);
  final prefsAsync = ref.watch(sharedPreferencesProvider);

  // Esperar a que SharedPreferences esté listo
  return prefsAsync.when(
    data: (prefs) => AuthNotifier(authRepository, supabaseClient, prefs),
    loading: () => throw Exception('SharedPreferences no está listo'),
    error: (error, stack) => throw Exception('Error al cargar SharedPreferences: $error'),
  );
});

/// Provider que expone el usuario actual si está autenticado.
/// 
/// Retorna null si no hay usuario autenticado.
final currentUserProvider = Provider<UsuarioEntity?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState is Authenticated) {
    return authState.user;
  }
  return null;
});

/// Provider que indica si el usuario está autenticado.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState is Authenticated;
});

